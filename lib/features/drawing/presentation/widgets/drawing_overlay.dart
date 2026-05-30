import 'package:flutter/material.dart';
import 'package:hooklove/features/drawing/domain/incoming_drawing.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

class DrawingOverlay extends StatefulWidget {
  final IncomingDrawing drawing;
  final VoidCallback onDismiss;

  const DrawingOverlay({
    super.key,
    required this.drawing,
    required this.onDismiss,
  });

  @override
  State<DrawingOverlay> createState() => _DrawingOverlayState();
}

class _DrawingOverlayState extends State<DrawingOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(220),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return CustomPaint(
                painter: _IncomingDrawingPainter(
                  strokes: widget.drawing.strokes,
                  canvasSize: size,
                ),
                size: size,
              );
            },
          ),
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.drawing.fromUserId.isNotEmpty
                        ? '${widget.drawing.fromUserId} te envió un dibujo'
                        : 'Dibujo recibido',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            top: 48,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: widget.onDismiss,
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'Desaparecerá automáticamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingDrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Size canvasSize;

  _IncomingDrawingPainter({required this.strokes, required this.canvasSize});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.deleted) continue;
      _drawStroke(canvas, stroke, size);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Size size) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = Color(stroke.color)
      ..strokeWidth = stroke.width * (size.width / 400)
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
  }

  @override
  bool shouldRepaint(covariant _IncomingDrawingPainter oldDelegate) => true;
}
