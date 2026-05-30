import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/core/network/firebase_providers.dart';
import 'package:hooklove/core/update/update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UpdateService(firestore);
});
