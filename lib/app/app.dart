import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/app/router/app_router.dart';
import 'package:hooklove/core/theme/app_theme.dart';
import 'package:hooklove/features/auth/domain/user.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/drawing/data/drawing_providers.dart';
import 'package:hooklove/features/drawing/domain/incoming_drawing.dart';
import 'package:hooklove/features/drawing/presentation/widgets/drawing_overlay.dart';
import 'package:hooklove/features/notifications/fcm_service.dart';

class HookLoveApp extends ConsumerStatefulWidget {
  const HookLoveApp({super.key});

  @override
  ConsumerState<HookLoveApp> createState() => _HookLoveAppState();
}

class _HookLoveAppState extends ConsumerState<HookLoveApp> {
  StreamSubscription? _incomingSubscription;

  @override
  void dispose() {
    _incomingSubscription?.cancel();
    super.dispose();
  }

  void _setupIncomingListener(AppUser? user) {
    _incomingSubscription?.cancel();
    _incomingSubscription = null;

    if (user == null || user.partnerId == null) return;

    final repository = ref.read(drawingRepositoryProvider(user.uid));
    _incomingSubscription =
        repository.watchIncomingDrawings(user.partnerId!).listen((drawing) {
      _showDrawingOverlay(drawing, user.uid, user.partnerId!);
    });
  }

  void _showDrawingOverlay(IncomingDrawing drawing, String userId, String pairId) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (dialogContext) => DrawingOverlay(
        drawing: drawing,
        onDismiss: () {
          final repo = ref.read(drawingRepositoryProvider(userId));
          repo.acknowledgeIncomingDrawing(pairId, drawing.id);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final tokenAsync = ref.watch(fcmTokenProvider);

    ref.listen(authStateProvider, (prev, next) {
      final user = next.valueOrNull;
      final token = tokenAsync.valueOrNull;
      if (user != null && token != null) {
        ref.read(fcmServiceProvider).saveToken(user.uid, token);
        ref.read(fcmServiceProvider).setupTokenRefresh(user.uid);
      }
      _setupIncomingListener(user);
    });

    return MaterialApp.router(
      title: 'HookLove',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
