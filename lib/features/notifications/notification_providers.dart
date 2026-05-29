import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final pendingNotificationProvider = StateProvider<RemoteMessage?>((ref) => null);
