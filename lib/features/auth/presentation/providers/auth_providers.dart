import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/features/auth/data/auth_providers.dart';
import 'package:hooklove/features/auth/domain/auth_repository.dart';
import 'package:hooklove/features/auth/domain/user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.watchAuthState();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(ref, repository);
});

class AuthController {
  final Ref _ref;
  final AuthRepository _repository;

  AuthController(this._ref, this._repository);

  Future<void> signInWithGoogle() async {
    await _repository.signInWithGoogle();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _repository.signInWithEmail(email, password);
  }

  Future<void> signUp(String email, String password, String displayName) async {
    await _repository.signUp(email, password, displayName);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }
}
