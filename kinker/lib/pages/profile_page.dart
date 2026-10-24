import 'package:flutter/material.dart';

import '../common_widgets/platform_alert_dialog.dart';
import '../models/user_profile.dart';
import '../services/services.dart';
import '../widgets/match_card.dart';
import 'profile_editor_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.me});

  final UserProfile me;

  Future<void> _signOut(BuildContext context) async {
    final auth = Services.of(context).auth;
    final confirmed = await const PlatformAlertDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelText: 'Cancel',
      confirmText: 'Logout',
    ).show(context);
    if (confirmed) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProfileEditorPage(uid: me.uid, existing: me),
            )),
          ),
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This is how others see you:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(child: MatchCard(profile: me)),
            const SizedBox(height: 16),
            const _AppearancePicker(),
          ],
        ),
      ),
    );
  }
}

class _AppearancePicker extends StatelessWidget {
  const _AppearancePicker();

  @override
  Widget build(BuildContext context) {
    final settings = Services.of(context).themeSettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: settings,
          builder: (context, mode, _) => SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) =>
                settings.setMode(selection.single),
          ),
        ),
      ],
    );
  }
}
