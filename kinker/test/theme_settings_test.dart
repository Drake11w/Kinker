import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinker/app.dart';
import 'package:kinker/models/user_profile.dart';
import 'package:kinker/services/auth.dart';
import 'package:kinker/services/memory_repository.dart';
import 'package:kinker/services/theme_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to the system theme', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await ThemeSettings.load()).value, ThemeMode.system);
  });

  test('persists the chosen mode', () async {
    SharedPreferences.setMockInitialValues({});
    await (await ThemeSettings.load()).setMode(ThemeMode.dark);
    expect((await ThemeSettings.load()).value, ThemeMode.dark);
  });

  testWidgets('the Profile tab switches the app to dark mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await ThemeSettings.load();
    final repository = MemoryRepository();
    await repository.saveProfile(
        const UserProfile(uid: 'me', name: 'Taylor', age: 25));

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(KinkerApp(
      auth: DemoAuth(initialUserId: 'me'),
      repository: repository,
      themeSettings: settings,
    ));
    await tester.pumpAndSettle();

    Brightness brightness() =>
        Theme.of(tester.element(find.text('Discover'))).brightness;
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settings.value, ThemeMode.dark);
    expect(brightness(), Brightness.dark);
  });
}
