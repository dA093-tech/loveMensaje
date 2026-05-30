import 'package:hooklove/features/drawing/domain/incoming_drawing.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

abstract class DrawingRepository {
  Stream<List<Stroke>> watchStrokes(String pairId);
  Future<void> addStroke(String pairId, Stroke stroke);
  Future<void> addStrokePoint(String pairId, String strokeId, Map<String, double> point);
  Future<void> clearCanvas(String pairId);
  Stream<bool> watchPartnerPresence(String pairId, String partnerId);
  Future<void> setPresence(String pairId, String userId, bool isDrawing);
  Future<List<Stroke>> getStrokeHistory(String pairId, {int limit = 50});

  Future<void> sendDrawing(String pairId, String fromUserId, List<Stroke> strokes);
  Stream<IncomingDrawing> watchIncomingDrawings(String pairId);
  Future<void> acknowledgeIncomingDrawing(String pairId, String drawingId);
}
