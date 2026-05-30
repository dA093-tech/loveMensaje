import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooklove/core/constants/app_constants.dart';
import 'package:hooklove/core/errors/app_exception.dart';
import 'package:hooklove/features/pairing/domain/pair.dart';
import 'package:hooklove/features/pairing/domain/pairing_repository.dart';

class PairingRepositoryImpl implements PairingRepository {
  final FirebaseFirestore _firestore;

  PairingRepositoryImpl(this._firestore);

  @override
  Future<String> generatePairingCode(String userId) async {
    final code = _generateCode();

    await _firestore.collection('users').doc(userId).update({
      'pairingCode': code,
    });

    return code;
  }

  @override
  Future<Pair> acceptPairingCode(String code, String userId) async {
    code = code.toUpperCase().trim();

    final usersSnapshot = await _firestore
        .collection('users')
        .where('pairingCode', isEqualTo: code)
        .limit(1)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      throw const AppException('Código inválido. Verifica e intenta de nuevo');
    }

    final partnerDoc = usersSnapshot.docs.first;
    final partnerId = partnerDoc.id;

    if (partnerId == userId && !kDebugMode) {
      throw const AppException('No puedes vincularte contigo mismo');
    }

    final existingPair = await getActivePair(userId);
    if (existingPair != null) {
      throw const AppException('Ya tienes una pareja activa. Desvincula primero');
    }

    final pairRef = await _firestore.collection('pairs').add({
      'user1Id': partnerId,
      'user2Id': userId,
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'activatedAt': DateTime.now().toIso8601String(),
    });

    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(userId), {
      'partnerId': partnerId,
      'pairingCode': null,
    });
    if (partnerId != userId) {
      batch.update(_firestore.collection('users').doc(partnerId), {
        'partnerId': userId,
        'pairingCode': null,
      });
    }
    await batch.commit();

    return Pair(
      pairId: pairRef.id,
      user1Id: partnerId,
      user2Id: userId,
      status: PairStatus.active,
      createdAt: DateTime.now(),
      activatedAt: DateTime.now(),
    );
  }

  @override
  Stream<Pair?> watchPair(String pairId) {
    return _firestore.collection('pairs').doc(pairId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Pair.fromMap(doc.id, doc.data()!);
    });
  }

  @override
  Future<Pair?> getActivePair(String userId) async {
    final snapshot = await _firestore
        .collection('pairs')
        .where('user1Id', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Pair.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
    }

    final snapshot2 = await _firestore
        .collection('pairs')
        .where('user2Id', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot2.docs.isNotEmpty) {
      return Pair.fromMap(snapshot2.docs.first.id, snapshot2.docs.first.data());
    }

    return null;
  }

  @override
  Future<void> disconnectPair(String pairId, String userId) async {
    final pairDoc = await _firestore.collection('pairs').doc(pairId).get();
    if (!pairDoc.exists) return;

    final pair = Pair.fromMap(pairId, pairDoc.data()!);

    final batch = _firestore.batch();
    batch.update(pairDoc.reference, {'status': 'disconnected'});
    batch.update(_firestore.collection('users').doc(pair.user1Id), {
      'partnerId': null,
    });
    if (pair.user1Id != pair.user2Id) {
      batch.update(_firestore.collection('users').doc(pair.user2Id), {
        'partnerId': null,
      });
    }
    await batch.commit();
  }

  String _generateCode() {
    final random = Random();
    return List.generate(
      AppConstants.pairingCodeLength,
      (_) => AppConstants.pairingCodeChars[random.nextInt(AppConstants.pairingCodeChars.length)],
    ).join();
  }
}
