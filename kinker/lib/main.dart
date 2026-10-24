import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/auth.dart';
import 'services/firestore_repository.dart';
import 'services/memory_repository.dart';

/// Pass `--dart-define=KINKER_DEMO=true` to skip Firebase entirely.
const bool forceDemo = bool.fromEnvironment('KINKER_DEMO');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (!forceDemo) {
    try {
      // Uses the native config files (google-services.json /
      // GoogleService-Info.plist). See README for setup.
      await Firebase.initializeApp();
      runApp(KinkerApp(
        auth: FirebaseAuthService(),
        repository: FirestoreRepository(),
      ));
      return;
    } catch (e) {
      debugPrint('Firebase unavailable, starting in demo mode: $e');
    }
  }

  runApp(KinkerApp(
    auth: DemoAuth(),
    repository: MemoryRepository.seeded(),
    isDemo: true,
  ));
}
