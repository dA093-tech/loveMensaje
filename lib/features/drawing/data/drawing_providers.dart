import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooklove/core/network/firebase_providers.dart';
import 'package:hooklove/features/drawing/data/drawing_repository_impl.dart';
import 'package:hooklove/features/drawing/domain/drawing_repository.dart';

final drawingRepositoryProvider = Provider.family<DrawingRepository, String>((ref, userId) {
  final rtdb = ref.watch(rtdbProvider);
  return DrawingRepositoryImpl(rtdb, userId);
});
