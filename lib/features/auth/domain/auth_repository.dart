import 'package:hooklove/features/auth/domain/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUp(String email, String password, String displayName);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> getCurrentUser();
}
