import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  StreamSubscription? _presenceSubscription;
  String? _currentStrokeId;
  List<Map<String, double>> _currentStrokePoints = [];

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
      color: state.selectedColor.toARGB32(),
      width: state.selectedWidth,
      points: [point],
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      currentStrokes: [...state.currentStrokes, stroke],
    );

    _repository.setPresence(_pairId, _userId, true);
  }

  void addPoint(Offset localPosition, Size canvasSize) {
    if (_currentStrokeId == null) return;

    final point = _normalizePoint(localPosition, canvasSize);
    _currentStrokePoints.add(point);

    final currentStrokes = [...state.currentStrokes];
    if (currentStrokes.isNotEmpty) {
      final lastStroke = currentStrokes.last;
      currentStrokes[currentStrokes.length - 1] = lastStroke.copyWith(
        points: [...lastStroke.points, point],
      );
      state = state.copyWith(currentStrokes: currentStrokes);
    }
  }

  void endStroke() {
    _currentStrokeId = null;
    _currentStrokePoints = [];

    final completedStrokes = [...state.strokes, ...state.currentStrokes];
    state = state.copyWith(
      strokes: completedStrokes,
      currentStrokes: [],
    );

    _repository.setPresence(_pairId, _userId, false);
  }

  void clearCanvas() {
    state = state.copyWith(strokes: [], currentStrokes: []);
    _currentStrokeId = null;
    _currentStrokePoints = [];
  }

  Future<void> sendDrawing() async {
    if (state.strokes.isEmpty) return;
    await _repository.sendDrawing(_pairId, _userId, state.strokes);
    clearCanvas();
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
    _presenceSubscription?.cancel();
    super.dispose();
  }
}
