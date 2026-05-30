import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooklove/core/network/firebase_providers.dart';

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

  final token = await messaging.getToken();
  return token;
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FcmService(firestore);
});

class FcmService {
  final FirebaseFirestore _firestore;

  FcmService(this._firestore);

  Future<void> saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeToken(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': null,
    });
  }

  Future<void> setupTokenRefresh(String userId) async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveToken(userId, newToken);
    });
  }
}
