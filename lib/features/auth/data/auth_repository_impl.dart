import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooklove/core/errors/app_exception.dart';
import 'package:hooklove/features/auth/domain/auth_repository.dart';
import 'package:hooklove/features/auth/domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._auth, this._firestore, this._googleSignIn);

  @override
  Stream<AppUser?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _getUserFromFirestore(firebaseUser);
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const AppException('Inicio de sesión cancelado');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final firebaseUser = result.user!;

      return _createOrGetUser(firebaseUser, googleUser.displayName ?? '');
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserFromFirestore(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<AppUser> signUp(String email, String password, String displayName) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(displayName);
      return _createOrGetUser(result.user!, displayName);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<AppUser> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw const AppException('No hay sesión activa');
    return _getUserFromFirestore(firebaseUser);
  }

  Future<AppUser> _getUserFromFirestore(User firebaseUser) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) {
      return _createUserDoc(firebaseUser);
    }
    return AppUser.fromMap(firebaseUser.uid, doc.data()!);
  }

  Future<AppUser> _createOrGetUser(User firebaseUser, String displayName) async {
    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return AppUser.fromMap(firebaseUser.uid, doc.data()!);
    }
    return _createUserDoc(firebaseUser, displayName);
  }

  Future<AppUser> _createUserDoc(User firebaseUser, [String? displayName]) async {
    final user = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName ?? firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }
}
