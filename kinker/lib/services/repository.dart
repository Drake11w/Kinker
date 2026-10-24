import '../models/chat_message.dart';
import '../models/match.dart';
import '../models/user_profile.dart';

/// Data access for profiles, swipes, matches and chat.
abstract class Repository {
  Stream<UserProfile?> watchProfile(String uid);
  Future<UserProfile?> fetchProfile(String uid);
  Future<void> saveProfile(UserProfile profile);

  /// Profiles [uid] has not swiped on yet, excluding themselves.
  Future<List<UserProfile>> fetchCandidates(String uid, {int limit = 20});

  /// Records a swipe. Returns the new [Match] when the like is mutual.
  Future<Match?> swipe(String uid, String targetUid, {required bool liked});

  Stream<List<Match>> watchMatches(String uid);
  Future<void> unmatch(String matchId);

  Stream<List<ChatMessage>> watchMessages(String matchId);
  Future<void> sendMessage(String matchId, String senderId, String text);
}
