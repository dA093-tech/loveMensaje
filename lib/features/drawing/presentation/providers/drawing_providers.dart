import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/core/constants/app_constants.dart';
import 'package:hooklove/core/utils/stroke_compressor.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/drawing/data/drawing_providers.dart';
import 'package:hooklove/features/drawing/domain/canvas_state.dart';
import 'package:hooklove/features/drawing/domain/drawing_repository.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

final canvasControllerProvider =
    StateNotifierProvider.family<CanvasController, CanvasState, String>((ref, pairId) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final userId = user?.uid ?? '';
  final partnerId = user?.partnerId ?? '';
  final partnerName = user?.displayName ?? 'Tu pareja';
  final repository = ref.watch(drawingRepositoryProvider(userId));

  return CanvasController(
    ref,
    repository,
    pairId,
    userId,
    partnerId,
    partnerName,
  );
});

class CanvasController extends StateNotifier<CanvasState> {
  final Ref _ref;
  final DrawingRepository _repository;
  final String _pairId;
  final String _userId;
  final String _partnerId;
  final String _partnerName;
  StreamSubscription? _strokeSubscription;
  StreamSubscription? _presenceSubscription;
  Timer? _throttleTimer;
  String? _currentStrokeId;
  List<Map<String, double>> _currentStrokePoints = [];
  int _pointCount = 0;

  CanvasController(
    this._ref,
    this._repository,
    this._pairId,
    this._userId,
    this._partnerId,
    this._partnerName,
  ) : super(const CanvasState(strokes: [])) {
    _init();
  }

  void _init() {
    _strokeSubscription = _repository.watchStrokes(_pairId).listen((strokes) {
      state = state.copyWith(strokes: strokes);
    });

    _presenceSubscription = _repository
        .watchPartnerPresence(_pairId, _partnerId)
        .listen((isDrawing) {
      state = state.copyWith(
        partnerDrawing: isDrawing,
        partnerName: _partnerName,
      );
    });
  }

  void startStroke(Offset localPosition, Size canvasSize) {
    final point = _normalizePoint(localPosition, canvasSize);
    _currentStrokePoints = [point];
    _currentStrokeId = '${_userId}_${DateTime.now().millisecondsSinceEpoch}';

    final stroke = Stroke(
      id: _currentStrokeId!,
      userId: _userId,
      tool: state.selectedTool,
      color: state.selectedColor.value,
      width: state.selectedWidth,
      points: [point],
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      currentStrokes: [...state.currentStrokes, stroke],
    );

    _repository.addStroke(_pairId, stroke);
    _repository.setPresence(_pairId, _userId, true);
  }

  void addPoint(Offset localPosition, Size canvasSize) {
    if (_currentStrokeId == null) return;

    final point = _normalizePoint(localPosition, canvasSize);
    _currentStrokePoints.add(point);
    _pointCount++;

    if (_pointCount >= AppConstants.syncThrottleMs) {
      _flushPoints();
    }

    final currentStrokes = [...state.currentStrokes];
    if (currentStrokes.isNotEmpty) {
      final lastStroke = currentStrokes.last;
      currentStrokes[currentStrokes.length - 1] = lastStroke.copyWith(
        points: [...lastStroke.points, point],
      );
      state = state.copyWith(currentStrokes: currentStrokes);
    }

    _throttleTimer?.cancel();
    _throttleTimer = Timer(
      const Duration(milliseconds: AppConstants.syncThrottleMs),
      _flushPoints,
    );
  }

  void endStroke() {
    _flushPoints();
    _currentStrokeId = null;
    _currentStrokePoints = [];
    _pointCount = 0;
    _throttleTimer?.cancel();

    final completedStrokes = [...state.strokes, ...state.currentStrokes];
    state = state.copyWith(
      strokes: completedStrokes,
      currentStrokes: [],
    );

    _repository.setPresence(_pairId, _userId, false);
  }

  void _flushPoints() {
    if (_currentStrokeId == null || _currentStrokePoints.isEmpty) return;

    final compressedPoints = StrokeCompressor.removeDuplicates(_currentStrokePoints);
    final tolerance = 0.005;

    final optimizedPoints = StrokeCompressor.compress(compressedPoints, tolerance);

    for (final point in optimizedPoints) {
      _repository.addStrokePoint(_pairId, _currentStrokeId!, point);
    }
  }

  void clearCanvas() {
    _repository.clearCanvas(_pairId);
    state = state.copyWith(strokes: [], currentStrokes: []);
    _currentStrokeId = null;
    _currentStrokePoints = [];
    _pointCount = 0;
  }

  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void setWidth(double width) {
    state = state.copyWith(selectedWidth: width);
  }

  void setTool(Tool tool) {
    state = state.copyWith(selectedTool: tool);
  }

  Map<String, double> _normalizePoint(Offset point, Size size) {
    return {
      'x': (point.dx / size.width).clamp(0.0, 1.0),
      'y': (point.dy / size.height).clamp(0.0, 1.0),
    };
  }

  @override
  void dispose() {
    _strokeSubscription?.cancel();
    _presenceSubscription?.cancel();
    _throttleTimer?.cancel();
    super.dispose();
  }
}
