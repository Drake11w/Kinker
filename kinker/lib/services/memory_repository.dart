import 'dart:async';

import '../models/chat_message.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import 'repository.dart';

/// In-memory [Repository] used for demo mode (no Firebase project) and tests.
class MemoryRepository implements Repository {
  MemoryRepository({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// A repository pre-populated with sample profiles. Some of them already
  /// like everyone, so liking them produces a match straight away.
  factory MemoryRepository.seeded() {
    final repo = MemoryRepository();
    for (final p in demoProfiles) {
      repo._profiles[p.uid] = p;
    }
    for (final uid in _eagerDemoUsers) {
      repo._likesEveryone.add(uid);
    }
    return repo;
  }

  final DateTime Function() _clock;
  final Map<String, UserProfile> _profiles = {};
  final Map<String, Map<String, bool>> _swipes = {};
  final Set<String> _likesEveryone = {};
  final Map<String, Match> _matches = {};
  final Map<String, List<ChatMessage>> _messages = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextMessageId = 1;

  /// Makes [uid] like whoever they are shown (used to stage matches).
  void setLikesEveryone(String uid) => _likesEveryone.add(uid);

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  void _notify() => _changes.add(null);

  @override
  Stream<UserProfile?> watchProfile(String uid) => _watch(() => _profiles[uid]);

  @override
  Future<UserProfile?> fetchProfile(String uid) async => _profiles[uid];

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profiles[profile.uid] = profile;
    _notify();
  }

  @override
  Future<List<UserProfile>> fetchCandidates(String uid,
      {int limit = 20}) async {
    final swiped = _swipes[uid] ?? const {};
    return _profiles.values
        .where((p) => p.uid != uid && !swiped.containsKey(p.uid))
        .take(limit)
        .toList();
  }

  @override
  Future<Match?> swipe(String uid, String targetUid,
      {required bool liked}) async {
    (_swipes[uid] ??= {})[targetUid] = liked;
    if (!liked) return null;

    final theyLiked =
        _swipes[targetUid]?[uid] ?? _likesEveryone.contains(targetUid);
    if (!theyLiked) return null;

    final id = Match.idFor(uid, targetUid);
    final match = _matches[id] ??=
        Match(id: id, userIds: [uid, targetUid]..sort(), createdAt: _clock());
    _notify();
    return match;
  }

  @override
  Stream<List<Match>> watchMatches(String uid) => _watch(() =>
      _matches.values.where((m) => m.userIds.contains(uid)).toList()
        ..sort((a, b) => b.sortTime.compareTo(a.sortTime)));

  @override
  Future<void> unmatch(String matchId) async {
    _matches.remove(matchId);
    _messages.remove(matchId);
    _notify();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String matchId) =>
      _watch(() => List.unmodifiable(_messages[matchId] ?? const []));

  @override
  Future<void> sendMessage(String matchId, String senderId, String text) async {
    final match = _matches[matchId];
    if (match == null) throw StateError('No match $matchId');
    final now = _clock();
    (_messages[matchId] ??= []).add(ChatMessage(
      id: '${_nextMessageId++}',
      senderId: senderId,
      text: text,
      sentAt: now,
    ));
    _matches[matchId] = match.copyWith(lastMessage: text, updatedAt: now);
    _notify();
  }
}

const _eagerDemoUsers = ['demo-ava', 'demo-sam', 'demo-riley'];

const demoProfiles = <UserProfile>[
  UserProfile(
    uid: 'demo-ava',
    name: 'Ava',
    age: 27,
    bio: 'Climber, coffee snob, and amateur astronomer.',
    interests: ['Climbing', 'Coffee', 'Stargazing'],
  ),
  UserProfile(
    uid: 'demo-jordan',
    name: 'Jordan',
    age: 31,
    bio: 'Building furniture on weekends. Ask me about dovetail joints.',
    interests: ['Woodworking', 'Jazz', 'Cycling'],
  ),
  UserProfile(
    uid: 'demo-sam',
    name: 'Sam',
    age: 24,
    bio: 'Board game night host. I will teach you any game in five minutes.',
    interests: ['Board games', 'Cooking', 'Sci-fi'],
  ),
  UserProfile(
    uid: 'demo-morgan',
    name: 'Morgan',
    age: 29,
    bio: 'Trail runner and terrible gardener.',
    interests: ['Running', 'Plants', 'Podcasts'],
  ),
  UserProfile(
    uid: 'demo-riley',
    name: 'Riley',
    age: 33,
    bio: 'Photographer who travels for the food.',
    interests: ['Photography', 'Travel', 'Street food'],
  ),
  UserProfile(
    uid: 'demo-casey',
    name: 'Casey',
    age: 26,
    bio: 'Learning the cello at 26. My neighbours are very patient.',
    interests: ['Music', 'Reading', 'Yoga'],
  ),
];
