import 'package:flutter_test/flutter_test.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

void main() {
  group('Stroke', () {
    test('toMap and fromMap round-trip correctly', () {
      final stroke = Stroke(
        id: 'test_id',
        userId: 'user1',
        tool: Tool.pen,
        color: 0xFFFFFFFF,
        width: 3.0,
        points: const [{'x': 0.5, 'y': 0.5}],
        timestamp: DateTime.now(),
      );

      final map = stroke.toMap();
      final restored = Stroke.fromMap(stroke.id, map);

      expect(restored.id, stroke.id);
      expect(restored.userId, stroke.userId);
      expect(restored.tool, stroke.tool);
      expect(restored.color, stroke.color);
      expect(restored.width, stroke.width);
      expect(restored.points.length, stroke.points.length);
    });

    test('copyWith creates modified copy', () {
      final stroke = Stroke(
        id: 'id1',
        userId: 'user1',
        tool: Tool.pen,
        color: 0xFFFFFFFF,
        width: 3.0,
        points: [],
        timestamp: DateTime.now(),
      );

      final modified = stroke.copyWith(width: 5.0, tool: Tool.eraser);
      expect(modified.width, 5.0);
      expect(modified.tool, Tool.eraser);
      expect(modified.id, stroke.id);
    });
  });
}
