import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooklove/features/auth/presentation/providers/auth_providers.dart';
import 'package:hooklove/features/auth/presentation/screens/login_screen.dart';
import 'package:hooklove/features/auth/presentation/screens/register_screen.dart';
import 'package:hooklove/features/auth/presentation/screens/splash_screen.dart';
import 'package:hooklove/features/home/presentation/screens/home_screen.dart';
import 'package:hooklove/features/pairing/presentation/screens/pair_screen.dart';
import 'package:hooklove/features/drawing/presentation/screens/canvas_screen.dart';
import 'package:hooklove/features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');
      final isOnboarding = state.matchedLocation.startsWith('/pair');

      if (isSplash && authState.isLoading) return null;

      if (!isLoggedIn) {
        if (isAuth) return null;
        return '/login';
      }

      if (isAuth) return '/home';

      final hasPartner = authState.valueOrNull?.partnerId != null;
      if (!hasPartner && !isOnboarding) return '/pair';
      if (hasPartner && (isOnboarding || isSplash)) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pair',
        name: 'pair',
        builder: (context, state) => const PairScreen(),
      ),
      GoRoute(
        path: '/canvas',
        name: 'canvas',
        builder: (context, state) => const CanvasScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
