import 'package:flutter_test/flutter_test.dart';
import 'package:kinker/models/user_profile.dart';
import 'package:kinker/services/memory_repository.dart';

UserProfile _profile(String uid) => UserProfile(uid: uid, name: uid, age: 30);

void main() {
  late MemoryRepository repo;

  setUp(() async {
    repo = MemoryRepository();
    for (final uid in ['me', 'a', 'b', 'c']) {
      await repo.saveProfile(_profile(uid));
    }
  });

  test('candidates exclude self and already-swiped profiles', () async {
    expect((await repo.fetchCandidates('me')).map((p) => p.uid), ['a', 'b', 'c']);
    await repo.swipe('me', 'a', liked: false);
    await repo.swipe('me', 'b', liked: true);
    expect((await repo.fetchCandidates('me')).map((p) => p.uid), ['c']);
  });

  test('a one-sided like does not match', () async {
    expect(await repo.swipe('me', 'a', liked: true), isNull);
    expect(await repo.watchMatches('me').first, isEmpty);
  });

  test('a mutual like creates a single match visible to both', () async {
    await repo.swipe('a', 'me', liked: true);
    final match = await repo.swipe('me', 'a', liked: true);
    expect(match, isNotNull);
    expect(match!.userIds, ['a', 'me']);
    expect((await repo.watchMatches('me').first).single.id, match.id);
    expect((await repo.watchMatches('a').first).single.id, match.id);
  });

  test('a like after being passed on does not match', () async {
    await repo.swipe('a', 'me', liked: false);
    expect(await repo.swipe('me', 'a', liked: true), isNull);
  });

  test('messages are stored and update the match preview', () async {
    await repo.swipe('a', 'me', liked: true);
    final match = (await repo.swipe('me', 'a', liked: true))!;
    await repo.sendMessage(match.id, 'me', 'hello');
    await repo.sendMessage(match.id, 'a', 'hey!');

    final messages = await repo.watchMessages(match.id).first;
    expect(messages.map((m) => m.text), ['hello', 'hey!']);
    expect((await repo.watchMatches('me').first).single.lastMessage, 'hey!');
  });

  test('unmatch removes the match and its messages', () async {
    await repo.swipe('a', 'me', liked: true);
    final match = (await repo.swipe('me', 'a', liked: true))!;
    await repo.sendMessage(match.id, 'me', 'hello');
    await repo.unmatch(match.id);
    expect(await repo.watchMatches('me').first, isEmpty);
    expect(await repo.watchMessages(match.id).first, isEmpty);
  });

  test('seeded demo data has eager users that match immediately', () async {
    final demo = MemoryRepository.seeded();
    await demo.saveProfile(_profile('me'));
    expect(await demo.swipe('me', 'demo-ava', liked: true), isNotNull);
    expect(await demo.swipe('me', 'demo-jordan', liked: true), isNull);
  });
}
