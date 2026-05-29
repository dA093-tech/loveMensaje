import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/core/theme/app_typography.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:hooklove/core/utils/haptic_util.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final pairingAsync = ref.watch(pairingStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _SectionHeader(title: 'Cuenta'),
            const SizedBox(height: 12),
            _SettingsCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceLight,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Icon(Icons.person, color: AppColors.textHint)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Usuario',
                          style: AppTypography.titleMedium,
                        ),
                        Text(
                          user?.email ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader(title: 'Pareja'),
            const SizedBox(height: 12),
            pairingAsync.when(
              data: (pair) {
                if (pair != null) {
                  return _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text('Vinculado', style: AppTypography.titleMedium),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Activo',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Desvincular pareja'),
                                  content: const Text(
                                    '¿Estás seguro? Se perderá la conexión y los dibujos compartidos.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('Desvincular'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(pairingControllerProvider).disconnect();
                                HapticUtil.notificationError();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Desvincular pareja'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _SettingsCard(
                  child: Column(
                    children: [
                      const Icon(Icons.link_off, size: 40, color: AppColors.textHint),
                      const SizedBox(height: 8),
                      Text(
                        'Sin pareja vinculada',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/pair'),
                        child: const Text('Vincular ahora'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const _SettingsCard(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            _SectionHeader(title: 'App'),
            const SizedBox(height: 12),
            _SettingsCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.info_outline,
                    title: 'Versión',
                    trailing: Text(
                      '1.0.0',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesión',
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text('¿Estás seguro de cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(authControllerProvider).signOut();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTypography.bodyLarge),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
