import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/core/network/firebase_providers.dart';
import 'package:hooklove/features/pairing/data/pairing_repository_impl.dart';
import 'package:hooklove/features/pairing/domain/pairing_repository.dart';

final pairingRepositoryProvider = Provider<PairingRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PairingRepositoryImpl(firestore);
});
