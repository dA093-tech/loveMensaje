import 'dart:math';

class StrokeCompressor {
  StrokeCompressor._();

  static List<Map<String, double>> compress(List<Map<String, double>> points, double tolerance) {
    if (points.length <= 2) return points;

    return ramerDouglasPeucker(points, tolerance);
  }

  static List<Map<String, double>> ramerDouglasPeucker(
    List<Map<String, double>> points,
    double epsilon,
  ) {
    if (points.length <= 2) return points;

    double dmax = 0;
    int index = 0;

    final first = points.first;
    final last = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final d = perpendicularDistance(points[i], first, last);
      if (d > dmax) {
        dmax = d;
        index = i;
      }
    }

    if (dmax > epsilon) {
      final left = ramerDouglasPeucker(points.sublist(0, index + 1), epsilon);
      final right = ramerDouglasPeucker(points.sublist(index), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }

  static double perpendicularDistance(
    Map<String, double> point,
    Map<String, double> lineStart,
    Map<String, double> lineEnd,
  ) {
    final dx = lineEnd['x']! - lineStart['x']!;
    final dy = lineEnd['y']! - lineStart['y']!;

    final num = (dy * point['x']! - dx * point['y']! +
            lineEnd['x']! * lineStart['y']! -
            lineEnd['y']! * lineStart['x']!)
        .abs();
    final den = sqrt(dx * dx + dy * dy);

    if (den == 0) return (point['x']! - lineStart['x']!).abs();

    return num / den;
  }

  static List<Map<String, double>> removeDuplicates(List<Map<String, double>> points) {
    if (points.isEmpty) return points;

    final result = <Map<String, double>>[points.first];
    for (int i = 1; i < points.length; i++) {
      final prev = result.last;
      final curr = points[i];
      if ((curr['x']! - prev['x']!).abs() > 0.001 ||
          (curr['y']! - prev['y']!).abs() > 0.001) {
        result.add(curr);
      }
    }
    return result;
  }
}
