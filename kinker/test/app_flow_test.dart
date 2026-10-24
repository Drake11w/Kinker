import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinker/app.dart';
import 'package:kinker/services/auth.dart';
import 'package:kinker/services/memory_repository.dart';

void main() {
  testWidgets('register, create a profile, match and chat', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repository = MemoryRepository.seeded();
    await tester.pumpWidget(KinkerApp(
      auth: DemoAuth(),
      repository: repository,
      isDemo: true,
    ));
    await tester.pumpAndSettle();

    // Register.
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'me@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'secret123');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();

    // Onboarding rejects under-18s.
    expect(find.text('Create your profile'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('name')), 'Taylor');
    await tester.enterText(find.byKey(const Key('age')), '17');
    await tester.tap(find.byKey(const Key('saveProfile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('at least 18'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('age')), '25');
    await tester.enterText(find.byKey(const Key('interests')), 'Hiking, Jazz');
    await tester.tap(find.byKey(const Key('saveProfile')));
    await tester.pumpAndSettle();

    // Discover: the first seeded profile (Ava) already likes everyone.
    expect(find.text('Ava, 27'), findsOneWidget);
    await tester.tap(find.byTooltip('Like'));
    await tester.pumpAndSettle();
    expect(find.text('It\'s a match!'), findsOneWidget);

    await tester.tap(find.text('Send a message'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('messageInput')), 'Hi Ava!');
    await tester.tap(find.byKey(const Key('sendMessage')));
    await tester.pumpAndSettle();
    expect(find.text('Hi Ava!'), findsOneWidget);

    // The match appears in the Matches tab with the latest message.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Jordan, 31'), findsOneWidget);
    await tester.tap(find.text('Matches'));
    await tester.pumpAndSettle();
    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Hi Ava!'), findsOneWidget);

    // Sign out returns to the sign-in screen.
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('submit')), findsOneWidget);
  });

  testWidgets('shows an error for bad credentials', (tester) async {
    await tester.pumpWidget(KinkerApp(
      auth: DemoAuth(),
      repository: MemoryRepository(),
      isDemo: true,
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email')), 'nobody@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'wrongpass');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
