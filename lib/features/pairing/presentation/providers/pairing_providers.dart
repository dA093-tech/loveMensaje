import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/features/auth/data/auth_providers.dart';
import 'package:hooklove/features/pairing/data/pairing_providers.dart';
import 'package:hooklove/features/pairing/domain/pair.dart';
import 'package:hooklove/features/pairing/domain/pairing_repository.dart';

final pairingStateProvider = FutureProvider<Pair?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final repository = ref.watch(pairingRepositoryProvider);
  return repository.getActivePair(user.uid);
});

final pairingControllerProvider = Provider<PairingController>((ref) {
  final repository = ref.watch(pairingRepositoryProvider);
  final userId = ref.watch(authStateProvider).valueOrNull?.uid;
  return PairingController(ref, repository, userId ?? '');
});

class PairingController {
  final Ref _ref;
  final PairingRepository _repository;
  final String _userId;

  PairingController(this._ref, this._repository, this._userId);

  Future<String> generateCode() async {
    return _repository.generatePairingCode(_userId);
  }

  Future<Pair> acceptCode(String code) async {
    return _repository.acceptPairingCode(code, _userId);
  }

  Future<void> disconnect() async {
    final pair = await _repository.getActivePair(_userId);
    if (pair != null) {
      await _repository.disconnectPair(pair.pairId, _userId);
    }
  }
}
