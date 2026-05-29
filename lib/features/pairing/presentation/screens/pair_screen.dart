import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/core/constants/app_constants.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/core/theme/app_typography.dart';
import 'package:hooklove/core/errors/app_exception.dart';
import 'package:hooklove/core/utils/haptic_util.dart';
import 'package:hooklove/features/pairing/presentation/providers/pairing_providers.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  final _codeController = TextEditingController();
  bool _isGenerating = false;
  bool _isAccepting = false;
  String? _generatedCode;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);
    try {
      final code = await ref.read(pairingControllerProvider).generateCode();
      setState(() => _generatedCode = code);
      HapticUtil.success();
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error al generar código');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _acceptCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != AppConstants.pairingCodeLength) {
      _showError('El código debe tener ${AppConstants.pairingCodeLength} caracteres');
      return;
    }

    setState(() => _isAccepting = true);
    try {
      await ref.read(pairingControllerProvider).acceptCode(code);
      HapticUtil.success();
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error al vincular');
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Vincular pareja')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Conéctate con tu pareja',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Genera un código para que tu pareja ingrese,\no ingresa el código que ella te compartió',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              if (_generatedCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Column(
                    children: [
                      Text('Tu código', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode!));
                          HapticUtil.light();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _generatedCode!,
                            style: AppTypography.displayLarge.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para copiar',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('o', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
              ],
              Text(
                'Ingresa el código de tu pareja',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: AppConstants.pairingCodeLength,
                textAlign: TextAlign.center,
                style: AppTypography.headlineLarge.copyWith(
                  letterSpacing: 8,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  hintStyle: AppTypography.headlineLarge.copyWith(
                    letterSpacing: 8,
                    color: AppColors.textHint,
                  ),
                  counterText: '',
                ),
                onFieldSubmitted: (_) => _acceptCode(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isAccepting ? null : _acceptCode,
                child: _isAccepting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Vincular'),
              ),
              if (_generatedCode == null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isGenerating ? null : _generateCode,
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Generar mi código'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
