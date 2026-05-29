import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/app/router/app_router.dart';
import 'package:hooklove/core/theme/app_theme.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/notifications/fcm_service.dart';

class HookLoveApp extends ConsumerWidget {
  const HookLoveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final tokenAsync = ref.watch(fcmTokenProvider);

    ref.listen(authStateProvider, (prev, next) {
      final user = next.valueOrNull;
      final token = tokenAsync.valueOrNull;
      if (user != null && token != null) {
        ref.read(fcmServiceProvider).saveToken(user.uid, token);
        ref.read(fcmServiceProvider).setupTokenRefresh(user.uid);
      }
    });

    return MaterialApp.router(
      title: 'HookLove',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
