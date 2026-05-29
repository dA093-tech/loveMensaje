import 'package:hooklove/features/pairing/domain/pair.dart';

abstract class PairingRepository {
  Future<String> generatePairingCode(String userId);
  Future<Pair> acceptPairingCode(String code, String userId);
  Stream<Pair?> watchPair(String pairId);
  Future<void> disconnectPair(String pairId, String userId);
  Future<Pair?> getActivePair(String userId);
}
