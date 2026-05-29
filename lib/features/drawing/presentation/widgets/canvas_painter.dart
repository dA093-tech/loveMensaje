import 'package:flutter/material.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

class CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Stroke> currentStrokes;
  final String currentUserId;
  final Size canvasSize;

  CanvasPainter({
    required this.strokes,
    required this.currentStrokes,
    required this.currentUserId,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    for (final stroke in strokes) {
      if (stroke.deleted) continue;
      _drawStroke(canvas, stroke, size);
    }

    for (final stroke in currentStrokes) {
      _drawStroke(canvas, stroke, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.canvasBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = AppColors.canvasGrid
      ..strokeWidth = 0.5;

    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Size size) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.tool == Tool.eraser
          ? AppColors.canvasBackground
          : Color(stroke.color)
      ..strokeWidth = stroke.width * _scaleFactor(size)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path();
    bool first = true;

    for (final point in stroke.points) {
      final dx = point['x']! * size.width;
      final dy = point['y']! * size.height;

      if (first) {
        path.moveTo(dx, dy);
        first = false;
      } else {
        path.lineTo(dx, dy);
      }
    }

    canvas.drawPath(path, paint);

    if (stroke.userId != currentUserId) {
      _drawPartnerDot(canvas, stroke.points.last, size);
    }
  }

  void _drawPartnerDot(Canvas canvas, Map<String, double> lastPoint, Size size) {
    final dx = lastPoint['x']! * size.width;
    final dy = lastPoint['y']! * size.height;

    final dotPaint = Paint()
      ..color = AppColors.secondary.withAlpha(180)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dx, dy), 4, dotPaint);
  }

  double _scaleFactor(Size size) {
    return size.width / 400;
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
