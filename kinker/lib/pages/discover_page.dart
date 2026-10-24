import 'package:flutter/material.dart';

import '../models/match.dart';
import '../models/user_profile.dart';
import '../services/services.dart';
import '../widgets/profile_photo.dart';
import '../widgets/swipe_deck.dart';
import 'chat_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, required this.me});

  final UserProfile me;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _deck = SwipeDeckController();
  List<UserProfile> _candidates = [];
  bool _loading = true;
  bool _started = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (!_loading || _error != null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final candidates =
          await Services.of(context).repository.fetchCandidates(widget.me.uid);
      if (mounted) setState(() => _candidates = candidates);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onSwipe(UserProfile profile, bool liked) async {
    setState(() => _candidates = _candidates.sublist(1));
    final repository = Services.of(context).repository;
    try {
      final match =
          await repository.swipe(widget.me.uid, profile.uid, liked: liked);
      if (match != null && mounted) await _celebrate(match, profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Swipe failed: $e')));
      }
    }
    if (mounted && _candidates.isEmpty) await _load();
  }

  Future<void> _celebrate(Match match, UserProfile other) async {
    final openChat = await showDialog<bool>(
      context: context,
      builder: (context) => _MatchDialog(me: widget.me, other: other),
    );
    if (openChat == true && mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatPage(match: match, me: widget.me, other: other),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kinker')),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _candidates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _EmptyState(
        icon: Icons.cloud_off,
        message: 'Couldn\'t load profiles.\n$_error',
        onRetry: _load,
      );
    }
    if (_candidates.isEmpty) {
      return _EmptyState(
        icon: Icons.hourglass_empty,
        message: 'You\'ve seen everyone for now.\nCheck back later!',
        onRetry: _load,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SwipeDeck(
              profiles: _candidates,
              onSwipe: _onSwipe,
              controller: _deck,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.large(
                heroTag: 'dislike',
                tooltip: 'Pass',
                backgroundColor: scheme.surfaceContainerHighest,
                foregroundColor: scheme.error,
                onPressed: _deck.dislike,
                child: const Icon(Icons.close, size: 40),
              ),
              FloatingActionButton.large(
                heroTag: 'like',
                tooltip: 'Like',
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                onPressed: _deck.like,
                child: const Icon(Icons.favorite, size: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchDialog extends StatelessWidget {
  const _MatchDialog({required this.me, required this.other});

  final UserProfile me;
  final UserProfile other;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('It\'s a match!', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileAvatar(profile: me, radius: 36),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.favorite, color: Colors.pink, size: 32),
              ),
              ProfileAvatar(profile: other, radius: 36),
            ],
          ),
          const SizedBox(height: 16),
          Text('You and ${other.name} like each other.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep swiping'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Send a message'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
