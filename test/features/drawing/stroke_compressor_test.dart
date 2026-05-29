import 'package:flutter_test/flutter_test.dart';
import 'package:hooklove/core/utils/stroke_compressor.dart';

void main() {
  group('StrokeCompressor', () {
    test('removeDuplicates removes consecutive same points', () {
      final points = [
        {'x': 0.5, 'y': 0.5},
        {'x': 0.5, 'y': 0.5},
        {'x': 0.5, 'y': 0.5},
        {'x': 0.6, 'y': 0.5},
        {'x': 0.6, 'y': 0.5},
      ];

      final result = StrokeCompressor.removeDuplicates(points);
      expect(result.length, 2);
      expect(result[0]['x'], 0.5);
      expect(result[1]['x'], 0.6);
    });

    test('compressor keeps endpoints for simple line', () {
      final points = [
        {'x': 0.0, 'y': 0.0},
        {'x': 0.1, 'y': 0.1},
        {'x': 0.2, 'y': 0.2},
        {'x': 0.3, 'y': 0.3},
        {'x': 0.4, 'y': 0.4},
        {'x': 0.5, 'y': 0.5},
      ];

      final result = StrokeCompressor.compress(points, 0.01);
      expect(result.length, 2);
      expect(result.first['x'], 0.0);
      expect(result.last['x'], 0.5);
    });
  });
}
