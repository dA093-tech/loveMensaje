import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/core/theme/app_typography.dart';
import 'package:hooklove/core/utils/haptic_util.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/drawing/domain/canvas_state.dart';
import 'package:hooklove/features/drawing/presentation/providers/drawing_providers.dart';
import 'package:hooklove/features/drawing/presentation/widgets/drawing_canvas.dart';
import 'package:hooklove/features/drawing/presentation/widgets/drawing_toolbar.dart';
import 'package:hooklove/features/drawing/presentation/widgets/partner_status_indicator.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  bool _showToolbar = true;
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final pairId = user?.partnerId;
    final userId = user?.uid ?? '';

    if (pairId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                'No tienes una pareja vinculada',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push('/pair'),
                child: const Text('Vincular pareja'),
              ),
            ],
          ),
        ),
      );
    }

    final canvasState = ref.watch(canvasControllerProvider(pairId));
    final controller = ref.read(canvasControllerProvider(pairId).notifier);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(canvasState, controller),
            Expanded(
              child: DrawingCanvas(
                state: canvasState,
                currentUserId: userId,
                onPanStart: (position, size) {
                  if (_showToolbar) {
                    HapticUtil.light();
                  }
                  controller.startStroke(position, size);
                },
                onPanUpdate: (position, size) {
                  controller.addPoint(position, size);
                },
                onPanEnd: () {
                  controller.endStroke();
                },
              ),
            ),
            if (_showToolbar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                child: DrawingToolbar(
                  state: canvasState,
                  onUndo: () {},
                  onClear: () => controller.clearCanvas(),
                  onColorChanged: (color) => controller.setColor(color),
                  onWidthChanged: (width) => controller.setWidth(width),
                  onToolChanged: (tool) => controller.setTool(tool),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(CanvasState canvasState, CanvasController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: () {
              if (_isFullscreen) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                setState(() => _isFullscreen = false);
              }
              context.pop();
            },
          ),
          const Spacer(),
          PartnerStatusIndicator(
            isDrawing: canvasState.partnerDrawing,
            partnerName: canvasState.partnerName,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded, size: 20),
            color: canvasState.strokes.isEmpty ? AppColors.textHint : AppColors.primary,
            onPressed: canvasState.strokes.isEmpty
                ? null
                : () {
                    controller.sendDrawing();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dibujo enviado'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
              size: 20,
            ),
            color: AppColors.textSecondary,
            onPressed: () {
              setState(() => _isFullscreen = !_isFullscreen);
              if (_isFullscreen) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              } else {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.touch_app_rounded, size: 20),
            color: _showToolbar ? AppColors.primary : AppColors.textSecondary,
            onPressed: () => setState(() => _showToolbar = !_showToolbar),
          ),
        ],
      ),
    );
  }
}
