# Kinker

A swipe-to-match social app built with Flutter and Firebase.

- **Sign in / register** with email and password (with password reset).
- **Create a profile**: name, age (18+ only), bio, interests and an optional photo link.
- **Discover**: drag cards right to like or left to pass, or use the buttons.
- **Match**: when two people like each other, both get a match and an "It's a match!" prompt.
- **Chat**: real-time messaging with each match, plus unmatch.

## Running it

The Flutter app lives in [`kinker/`](kinker/); run the commands below from there.
Requires Dart 3.13+ (developed on Flutter 3.47).

```sh
flutter pub get
flutter run
```

### Demo mode (no Firebase needed)

If Firebase isn't configured, the app falls back to **demo mode**: auth and data live in
memory on the device, seeded with sample profiles. Some of them already like everyone, so
you can see matching and chat right away. Force it with:

```sh
flutter run --dart-define=KINKER_DEMO=true
# or in a browser
flutter run -d chrome --dart-define=KINKER_DEMO=true
```

### Connecting Firebase

1. Create a Firebase project and enable **Authentication → Email/Password** and **Cloud Firestore**.
2. Add the apps and drop in the native config files (these are git-ignored):
   - Android (`com.example.kinker`): `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist` (add it to the Runner target in Xcode)
3. Deploy the security rules: `firebase deploy --only firestore:rules`

The Google Services Gradle plugin is applied automatically once `google-services.json` exists.

## Project layout

```
kinker/lib/
  main.dart                 Startup: Firebase, or demo-mode fallback
  app.dart                  MaterialApp + theme
  models/                   UserProfile, Match, ChatMessage
  services/
    auth.dart               BaseAuth, FirebaseAuthService, DemoAuth
    repository.dart         Repository interface (profiles, swipes, matches, chat)
    firestore_repository.dart
    memory_repository.dart  In-memory implementation + demo profiles
    services.dart           InheritedWidget exposing the services
  pages/                    Root (auth gate), sign-in, profile editor, home tabs,
                            discover, matches, chat, profile
  widgets/                  SwipeDeck, MatchCard, avatar helpers
  common_widgets/           Platform-adaptive (Material/Cupertino) widgets
kinker/firestore.rules      Firestore security rules
```

### Firestore data model

| Path | Fields |
| --- | --- |
| `users/{uid}` | `name`, `age`, `bio`, `interests`, `photoUrl` |
| `users/{uid}/swipes/{targetUid}` | `liked`, `at` |
| `matches/{uidA_uidB}` | `userIds`, `createdAt`, `updatedAt`, `lastMessage` |
| `matches/{id}/messages/{id}` | `senderId`, `text`, `sentAt` |

Match ids are the two sorted user ids joined with `_`, so both sides resolve to the same document.

## Tests

```sh
flutter analyze
flutter test
```

Tests cover the models, matching logic in the in-memory repository, the swipe deck
gestures, and a full register → profile → match → chat → sign-out flow.

## Ideas for next steps

- Photo uploads with Firebase Storage and `image_picker` (multiple photos per profile)
- Discovery preferences (age range, distance) and server-side candidate queues
- Push notifications for new matches and messages (Firebase Cloud Messaging)
- Block / report flows and moderation
