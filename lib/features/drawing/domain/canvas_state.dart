import 'package:flutter/material.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

class CanvasState {
  final List<Stroke> strokes;
  final List<Stroke> currentStrokes;
  final Color selectedColor;
  final double selectedWidth;
  final Tool selectedTool;
  final bool partnerDrawing;
  final String? partnerName;

  const CanvasState({
    required this.strokes,
    this.currentStrokes = const [],
    this.selectedColor = Colors.white,
    this.selectedWidth = 3.0,
    this.selectedTool = Tool.pen,
    this.partnerDrawing = false,
    this.partnerName,
  });

  CanvasState copyWith({
    List<Stroke>? strokes,
    List<Stroke>? currentStrokes,
    Color? selectedColor,
    double? selectedWidth,
    Tool? selectedTool,
    bool? partnerDrawing,
    String? partnerName,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      selectedTool: selectedTool ?? this.selectedTool,
      partnerDrawing: partnerDrawing ?? this.partnerDrawing,
      partnerName: partnerName ?? this.partnerName,
    );
  }
}
