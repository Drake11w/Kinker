import 'package:flutter/material.dart';

import '../models/match.dart';
import '../models/user_profile.dart';
import '../services/services.dart';
import '../widgets/profile_photo.dart';
import 'chat_page.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key, required this.me});

  final UserProfile me;

  @override
  Widget build(BuildContext context) {
    final repository = Services.of(context).repository;
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: StreamBuilder<List<Match>>(
        stream: repository.watchMatches(me.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Couldn\'t load matches.\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final matches = snapshot.data!;
          if (matches.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No matches yet.\nWhen someone you like likes you back, '
                  'they\'ll show up here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: matches.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) =>
                _MatchTile(key: ValueKey(matches[i].id), match: matches[i], me: me),
          );
        },
      ),
    );
  }
}

class _MatchTile extends StatefulWidget {
  const _MatchTile({super.key, required this.match, required this.me});

  final Match match;
  final UserProfile me;

  @override
  State<_MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<_MatchTile> {
  Future<UserProfile?>? _other;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _other ??= Services.of(context)
        .repository
        .fetchProfile(widget.match.otherUserId(widget.me.uid));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _other,
      builder: (context, snapshot) {
        final other = snapshot.data;
        if (other == null) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(snapshot.connectionState == ConnectionState.done
                ? 'Unavailable profile'
                : 'Loading…'),
          );
        }
        return ListTile(
          leading: ProfileAvatar(profile: other),
          title: Text(other.name),
          subtitle: Text(
            widget.match.lastMessage ?? 'Say hello 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ChatPage(match: widget.match, me: widget.me, other: other),
          )),
        );
      },
    );
  }
}
