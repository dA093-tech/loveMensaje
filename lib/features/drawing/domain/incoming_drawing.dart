import 'package:hooklove/features/drawing/domain/stroke.dart';

class IncomingDrawing {
  final String id;
  final String fromUserId;
  final List<Stroke> strokes;
  final DateTime timestamp;

  const IncomingDrawing({
    required this.id,
    required this.fromUserId,
    required this.strokes,
    required this.timestamp,
  });

  factory IncomingDrawing.fromMap(String id, Map<String, dynamic> map) {
    final rawStrokes = map['strokes'];
    List<Stroke> strokes = [];
    if (rawStrokes is List) {
      strokes = rawStrokes
          .map((s) => Stroke.fromMap(
              (s as Map)['id'] as String? ?? '', Map<String, dynamic>.from(s)))
          .toList();
    } else if (rawStrokes is Map) {
      strokes = (rawStrokes as Map<String, dynamic>)
          .values
          .map((s) => Stroke.fromMap('', Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return IncomingDrawing(
      id: id,
      fromUserId: map['fromUserId'] as String? ?? '',
      strokes: strokes,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'strokes': strokes.map((s) => {
            ...s.toMap(),
            'id': s.id,
          }).toList(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
