import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooklove/core/network/firebase_providers.dart';
import 'package:hooklove/features/auth/data/auth_repository_impl.dart';
import 'package:hooklove/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  final googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  return AuthRepositoryImpl(auth, firestore, googleSignIn);
});
