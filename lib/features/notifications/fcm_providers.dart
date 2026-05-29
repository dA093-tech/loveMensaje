import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/notifications/fcm_service.dart';

final fcmTokenSaveProvider = Provider<void>((ref) {
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
});
