import 'package:flutter_test/flutter_test.dart';
import 'package:hooklove/features/auth/domain/user.dart';

void main() {
  group('AppUser', () {
    test('hasPartner returns true when partnerId is set', () {
      final user = AppUser(
        uid: 'uid1',
        email: 'test@test.com',
        displayName: 'Test',
        partnerId: 'partner1',
        createdAt: DateTime.now(),
      );
      expect(user.hasPartner, true);
    });

    test('hasPartner returns false when partnerId is null', () {
      final user = AppUser(
        uid: 'uid1',
        email: 'test@test.com',
        displayName: 'Test',
        createdAt: DateTime.now(),
      );
      expect(user.hasPartner, false);
    });

    test('toMap and fromMap round-trip', () {
      final user = AppUser(
        uid: 'uid1',
        email: 'test@test.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        partnerId: 'partner1',
        pairingCode: 'ABC123',
        createdAt: DateTime(2026, 5, 29),
      );

      final map = user.toMap();
      final restored = AppUser.fromMap('uid1', map);

      expect(restored.uid, user.uid);
      expect(restored.email, user.email);
      expect(restored.displayName, user.displayName);
      expect(restored.photoUrl, user.photoUrl);
      expect(restored.partnerId, user.partnerId);
      expect(restored.pairingCode, user.pairingCode);
    });
  });
}
