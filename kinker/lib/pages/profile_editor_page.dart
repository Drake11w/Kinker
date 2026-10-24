import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/services.dart';

/// Creates a profile during onboarding, or edits an [existing] one.
class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({super.key, required this.uid, this.existing});

  final String uid;
  final UserProfile? existing;

  @override
  State<ProfileEditorPage> createState() => _ProfileEditorPageState();
}

class _ProfileEditorPageState extends State<ProfileEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _age =
      TextEditingController(text: widget.existing?.age.toString());
  late final _bio = TextEditingController(text: widget.existing?.bio);
  late final _interests =
      TextEditingController(text: widget.existing?.interests.join(', '));
  late final _photoUrl = TextEditingController(text: widget.existing?.photoUrl);
  bool _saving = false;

  bool get _isOnboarding => widget.existing == null;

  @override
  void dispose() {
    for (final c in [_name, _age, _bio, _interests, _photoUrl]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? validateAge(String? input) {
    final age = int.tryParse(input?.trim() ?? '');
    if (age == null) return 'Please enter your age';
    if (age < UserProfile.minimumAge) {
      return 'You must be at least ${UserProfile.minimumAge} to use Kinker';
    }
    if (age > 120) return 'Please enter a real age';
    return null;
  }

  static List<String> parseInterests(String input) => input
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .take(10)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repository = Services.of(context).repository;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final photo = _photoUrl.text.trim();
    final profile = UserProfile(
      uid: widget.uid,
      name: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      bio: _bio.text.trim(),
      interests: parseInterests(_interests.text),
      photoUrl: photo.isEmpty ? null : photo,
    );
    setState(() => _saving = true);
    try {
      await repository.saveProfile(profile);
      if (!_isOnboarding) navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not save your profile: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOnboarding ? 'Create your profile' : 'Edit profile'),
        actions: [
          if (_isOnboarding)
            TextButton(
              onPressed: () => Services.of(context).auth.signOut(),
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'First name'),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
            ),
            TextFormField(
              key: const Key('age'),
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: validateAge,
            ),
            TextFormField(
              key: const Key('bio'),
              controller: _bio,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'About you',
                alignLabelWithHint: true,
              ),
            ),
            TextFormField(
              key: const Key('interests'),
              controller: _interests,
              decoration: const InputDecoration(
                labelText: 'Interests',
                helperText: 'Separate with commas, e.g. Hiking, Jazz, Cooking',
              ),
            ),
            TextFormField(
              key: const Key('photoUrl'),
              controller: _photoUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return null;
                final uri = Uri.tryParse(value);
                return uri != null && uri.hasScheme && uri.host.isNotEmpty
                    ? null
                    : 'Please enter a full http(s) link';
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('saveProfile'),
              onPressed: _saving ? null : _save,
              child: Text(_isOnboarding ? 'Start swiping' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
