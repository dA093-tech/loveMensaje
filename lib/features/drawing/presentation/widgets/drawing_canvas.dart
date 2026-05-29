import 'package:flutter/material.dart';
import 'package:hooklove/features/drawing/domain/canvas_state.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';
import 'package:hooklove/features/drawing/presentation/widgets/canvas_painter.dart';

class DrawingCanvas extends StatelessWidget {
  final CanvasState state;
  final String currentUserId;
  final Function(Offset, Size) onPanStart;
  final Function(Offset, Size) onPanUpdate;
  final VoidCallback onPanEnd;

  const DrawingCanvas({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (details) => onPanStart(details.localPosition, canvasSize),
          onPanUpdate: (details) => onPanUpdate(details.localPosition, canvasSize),
          onPanEnd: (_) => onPanEnd(),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: CanvasPainter(
                strokes: state.strokes,
                currentStrokes: state.currentStrokes,
                currentUserId: currentUserId,
                canvasSize: canvasSize,
              ),
              size: canvasSize,
            ),
          ),
        );
      },
    );
  }
}
