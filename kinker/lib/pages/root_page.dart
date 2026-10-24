import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/services.dart';
import 'home_page.dart';
import 'profile_editor_page.dart';
import 'sign_in_page.dart';

/// Routes between sign-in, profile setup and the main app.
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = Services.of(context);
    return StreamBuilder<String?>(
      stream: services.auth.onAuthStateChanged,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _WaitingScreen();
        }
        final uid = authSnapshot.data;
        if (uid == null) return const SignInPage();

        return StreamBuilder<UserProfile?>(
          key: ValueKey(uid),
          stream: services.repository.watchProfile(uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _WaitingScreen();
            }
            final profile = profileSnapshot.data;
            if (profile == null) return ProfileEditorPage(uid: uid);
            return HomePage(me: profile);
          },
        );
      },
    );
  }
}

class _WaitingScreen extends StatelessWidget {
  const _WaitingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
