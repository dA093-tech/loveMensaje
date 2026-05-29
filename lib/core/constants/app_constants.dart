class AppConstants {
  AppConstants._();

  static const String appName = 'HookLove';
  static const String appVersion = '1.0.0';

  static const String rtdbRoot = 'drawings';
  static const String firestoreUsers = 'users';
  static const String firestorePairs = 'pairs';

  static const int maxStrokePoints = 500;
  static const int syncThrottleMs = 30;
  static const int maxHistoryDrawings = 50;
  static const int undoStackLimit = 30;

  static const double defaultStrokeWidth = 3.0;
  static const double minStrokeWidth = 1.0;
  static const double maxStrokeWidth = 20.0;

  static const double canvasMinZoom = 0.5;
  static const double canvasMaxZoom = 3.0;

  static const Duration presenceTimeout = Duration(seconds: 5);
  static const Duration reconnectionDelay = Duration(seconds: 2);

  static const String pairingCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int pairingCodeLength = 6;
}
