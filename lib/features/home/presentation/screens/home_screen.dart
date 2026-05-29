import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooklove/core/theme/app_colors.dart';
import 'package:hooklove/core/theme/app_typography.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceLight,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            (user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0]
                                    : '?')
                                .toUpperCase(),
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${user?.displayName ?? ''}',
                        style: AppTypography.titleMedium,
                      ),
                      if (user?.hasPartner == true)
                        Text(
                          'Conectado con tu pareja',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.draw_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Dibuja con tu pareja',
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.hasPartner == true
                          ? 'Toque el botón para empezar a dibujar juntos'
                          : 'Vincula una pareja para empezar a dibujar',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (user?.hasPartner == true) {
                            context.push('/canvas');
                          } else {
                            context.push('/pair');
                          }
                        },
                        icon: Icon(
                          user?.hasPartner == true
                              ? Icons.draw_rounded
                              : Icons.link_rounded,
                        ),
                        label: Text(
                          user?.hasPartner == true
                              ? 'Ir al canvas'
                              : 'Vincular pareja',
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
