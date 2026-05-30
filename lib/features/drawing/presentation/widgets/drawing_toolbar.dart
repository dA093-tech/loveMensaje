import 'package:flutter/material.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/features/drawing/domain/canvas_state.dart';
import 'package:hooklove/features/drawing/domain/stroke.dart';

class DrawingToolbar extends StatelessWidget {
  final CanvasState state;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<Tool> onToolChanged;
  final VoidCallback? onToggleToolbar;

  const DrawingToolbar({
    super.key,
    required this.state,
    required this.onUndo,
    required this.onClear,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onToolChanged,
    this.onToggleToolbar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolButton(
              icon: state.selectedTool == Tool.pen
                  ? Icons.draw
                  : Icons.draw_outlined,
              isActive: state.selectedTool == Tool.pen,
              onTap: () => onToolChanged(Tool.pen),
            ),
            _ToolButton(
              icon: Icons.auto_fix_high,
              isActive: state.selectedTool == Tool.eraser,
              onTap: () => onToolChanged(Tool.eraser),
            ),
            const SizedBox(width: 8),
            _ColorSelector(
              selectedColor: state.selectedColor,
              onColorChanged: onColorChanged,
            ),
            const SizedBox(width: 8),
            _WidthSelector(
              width: state.selectedWidth,
              onWidthChanged: onWidthChanged,
            ),
            const SizedBox(width: 8),
            _ToolButton(
              icon: Icons.undo_rounded,
              onTap: onUndo,
            ),
            _ToolButton(
              icon: Icons.delete_outline_rounded,
              onTap: onClear,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? AppColors.primary.withAlpha(40) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorSelector({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color>(
      offset: const Offset(0, -200),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onColorChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 180,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.drawingColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    onColorChanged(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: color == selectedColor
                          ? Border.all(color: Colors.white, width: 2)
                          : color == AppColors.white
                              ? Border.all(color: AppColors.textHint, width: 1)
                              : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
          border: selectedColor == AppColors.white
              ? Border.all(color: AppColors.textHint, width: 1.5)
              : null,
        ),
      ),
    );
  }
}

class _WidthSelector extends StatelessWidget {
  final double width;
  final ValueChanged<double> onWidthChanged;

  const _WidthSelector({
    required this.width,
    required this.onWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      offset: const Offset(0, -200),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onWidthChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 160,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [1.0, 3.0, 5.0, 8.0, 12.0, 18.0].map((w) {
                return GestureDetector(
                  onTap: () {
                    onWidthChanged(w);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: w * 3,
                          height: w.clamp(1.0, 12.0),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(w),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${w.toInt()}px',
                          style: TextStyle(
                            color: w == width
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: w == width
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (w == width)
                          const Icon(Icons.check,
                              size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: width.clamp(2.0, 16.0),
            height: width.clamp(2.0, 16.0),
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
