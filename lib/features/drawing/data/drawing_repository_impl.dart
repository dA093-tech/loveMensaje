import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:hooklove/core/constants/app_constants.dart';
import 'package:hooklove/features/drawing/domain/drawing_repository.dart';
import 'package:hooklove/features/drawing/domain/incoming_drawing.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  final FirebaseDatabase _rtdb;
  final String _userId;

  DrawingRepositoryImpl(this._rtdb, this._userId);

  DatabaseReference _strokesRef(String pairId) =>
      _rtdb.ref('${AppConstants.rtdbRoot}/$pairId/strokes');

  DatabaseReference _presenceRef(String pairId) =>
      _rtdb.ref('${AppConstants.rtdbRoot}/$pairId/presence');

  DatabaseReference _incomingRef(String pairId) =>
      _rtdb.ref('${AppConstants.rtdbRoot}/$pairId/incoming');

  @override
  Stream<List<Stroke>> watchStrokes(String pairId) {
    final controller = StreamController<List<Stroke>>.broadcast();
    final seenIds = <String>{};
    final strokes = <Stroke>[];

    final listener = _strokesRef(pairId).onChildAdded.listen((event) {
      final stroke = Stroke.fromMap(event.snapshot.key ?? '', Map<String, dynamic>.from(event.snapshot.value as Map));
      if (!seenIds.contains(stroke.id)) {
        seenIds.add(stroke.id);
        strokes.add(stroke);
        controller.add([...strokes]);
      }
    });

    final changeListener = _strokesRef(pairId).onChildChanged.listen((event) {
      final updated = Stroke.fromMap(event.snapshot.key ?? '', Map<String, dynamic>.from(event.snapshot.value as Map));
      final index = strokes.indexWhere((s) => s.id == updated.id);
      if (index != -1) {
        strokes[index] = updated;
        controller.add([...strokes]);
      } else {
        strokes.add(updated);
        controller.add([...strokes]);
      }
    });

    controller.onCancel = () {
      listener.cancel();
      changeListener.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> addStroke(String pairId, Stroke stroke) async {
    final data = stroke.toMap()..remove('points');
    await _strokesRef(pairId).child(stroke.id).set(data);
    for (final point in stroke.points) {
      await addStrokePoint(pairId, stroke.id, point);
    }
  }

  @override
  Future<void> addStrokePoint(String pairId, String strokeId, Map<String, double> point) async {
    await _strokesRef(pairId).child(strokeId).child('points').push().set(point);
  }

  @override
  Future<void> clearCanvas(String pairId) async {
    await _strokesRef(pairId).remove();
  }

  @override
  Stream<bool> watchPartnerPresence(String pairId, String partnerId) {
    return _presenceRef(pairId).child(partnerId).onValue.map((event) {
      if (event.snapshot.value == null) return false;
      return event.snapshot.value.toString() == 'drawing';
    });
  }

  @override
  Future<void> setPresence(String pairId, String userId, bool isDrawing) async {
    await _presenceRef(pairId).child(userId).set(isDrawing ? 'drawing' : 'idle');
  }

  @override
  Future<List<Stroke>> getStrokeHistory(String pairId, {int limit = 50}) async {
    final snapshot = await _strokesRef(pairId)
        .orderByChild('timestamp')
        .limitToLast(limit)
        .once();

    final strokes = <Stroke>[];
    if (snapshot.snapshot.value != null) {
      final map = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      map.forEach((key, value) {
        strokes.add(Stroke.fromMap(key, Map<String, dynamic>.from(value as Map)));
      });
    }
    strokes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return strokes;
  }

  @override
  Future<void> sendDrawing(String pairId, String fromUserId, List<Stroke> strokes) async {
    final drawing = IncomingDrawing(
      id: '',
      fromUserId: fromUserId,
      strokes: strokes,
      timestamp: DateTime.now(),
    );
    await _incomingRef(pairId).push().set(drawing.toMap());
  }

  @override
  Stream<IncomingDrawing> watchIncomingDrawings(String pairId) {
    final controller = StreamController<IncomingDrawing>.broadcast();
    final seenIds = <String>{};

    final listener = _incomingRef(pairId).onChildAdded.listen((event) {
      final id = event.snapshot.key ?? '';
      if (!seenIds.contains(id)) {
        seenIds.add(id);
        final drawing = IncomingDrawing.fromMap(
          id,
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
        controller.add(drawing);
      }
    });

    controller.onCancel = () {
      listener.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> acknowledgeIncomingDrawing(String pairId, String drawingId) async {
    await _incomingRef(pairId).child(drawingId).remove();
  }
}
