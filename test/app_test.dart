import 'package:flutter_test/flutter_test.dart';
import 'package:hooklove/app/app.dart';
import 'package:hooklove/core/theme/app_colors.dart';

void main() {
  testWidgets('App theme has correct primary color', (tester) async {
    final theme = AppTheme.darkTheme;
    expect(theme.colorScheme.primary, AppColors.primary);
  });
}
