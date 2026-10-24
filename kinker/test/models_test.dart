import 'package:flutter_test/flutter_test.dart';
import 'package:kinker/models/match.dart';
import 'package:kinker/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    const profile = UserProfile(
      uid: 'u1',
      name: 'Mary Jane',
      age: 25,
      bio: 'Hi',
      interests: ['Art', 'Film'],
      photoUrl: 'https://example.com/a.jpg',
    );

    test('round-trips through a map', () {
      expect(UserProfile.fromMap('u1', profile.toMap()), profile);
    });

    test('fromMap tolerates missing fields', () {
      final p = UserProfile.fromMap('u2', {});
      expect(p.name, '');
      expect(p.age, 0);
      expect(p.interests, isEmpty);
      expect(p.photoUrl, isNull);
    });

    test('initials use up to two words', () {
      expect(profile.initials, 'MJ');
      expect(profile.copyWith(name: 'cher').initials, 'C');
      expect(profile.copyWith(name: '  ').initials, '');
    });
  });

  group('Match', () {
    test('idFor is order independent', () {
      expect(Match.idFor('b', 'a'), Match.idFor('a', 'b'));
      expect(Match.idFor('a', 'b'), 'a_b');
    });

    test('otherUserId returns the counterpart', () {
      final m = Match(id: 'a_b', userIds: ['a', 'b'], createdAt: DateTime(2024));
      expect(m.otherUserId('a'), 'b');
      expect(m.otherUserId('b'), 'a');
    });
  });
}
