import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../models/match.dart';
import '../models/user_profile.dart';
import 'repository.dart';

/// Cloud Firestore layout:
///
///   users/{uid}                       profile fields
///   users/{uid}/swipes/{targetUid}    { liked, at }
///   matches/{matchId}                 { userIds, createdAt, updatedAt, lastMessage }
///   matches/{matchId}/messages/{id}   { senderId, text, sentAt }
///
/// See `firestore.rules` for the matching security rules.
class FirestoreRepository implements Repository {
  FirestoreRepository([FirebaseFirestore? firestore])
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _matches =>
      _db.collection('matches');
  CollectionReference<Map<String, dynamic>> _swipes(String uid) =>
      _users.doc(uid).collection('swipes');

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map(
        (doc) => doc.exists ? UserProfile.fromMap(doc.id, doc.data()!) : null);
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? UserProfile.fromMap(doc.id, doc.data()!) : null;
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<UserProfile>> fetchCandidates(String uid,
      {int limit = 20}) async {
    final swiped = await _swipes(uid).get();
    final excluded = {uid, ...swiped.docs.map((d) => d.id)};
    // Small-scale approach: over-fetch and filter on the client. A larger
    // deployment should precompute a per-user candidate queue server-side.
    final snapshot = await _users.limit(limit + excluded.length).get();
    return snapshot.docs
        .where((d) => !excluded.contains(d.id))
        .map((d) => UserProfile.fromMap(d.id, d.data()))
        .take(limit)
        .toList();
  }

  @override
  Future<Match?> swipe(String uid, String targetUid,
      {required bool liked}) async {
    await _swipes(uid).doc(targetUid).set({
      'liked': liked,
      'at': FieldValue.serverTimestamp(),
    });
    if (!liked) return null;

    final theirSwipe = await _swipes(targetUid).doc(uid).get();
    if (theirSwipe.data()?['liked'] != true) return null;

    final matchId = Match.idFor(uid, targetUid);
    final ref = _matches.doc(matchId);
    return _db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) return _matchFromDoc(existing);
      final now = DateTime.now();
      tx.set(ref, {
        'userIds': [uid, targetUid]..sort(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Match(
          id: matchId, userIds: [uid, targetUid]..sort(), createdAt: now);
    });
  }

  @override
  Stream<List<Match>> watchMatches(String uid) {
    // Sorted client-side to avoid requiring a composite index.
    return _matches
        .where('userIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs.map(_matchFromDoc).toList()
          ..sort((a, b) => b.sortTime.compareTo(a.sortTime)));
  }

  @override
  Future<void> unmatch(String matchId) => _matches.doc(matchId).delete();

  @override
  Stream<List<ChatMessage>> watchMessages(String matchId) {
    return _matches
        .doc(matchId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage(
                  id: d.id,
                  senderId: d['senderId'] as String,
                  text: d['text'] as String,
                  sentAt: _toDate(d.data()['sentAt']),
                ))
            .toList());
  }

  @override
  Future<void> sendMessage(String matchId, String senderId, String text) {
    final match = _matches.doc(matchId);
    final batch = _db.batch()
      ..set(match.collection('messages').doc(), {
        'senderId': senderId,
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
      })
      ..update(match, {
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    return batch.commit();
  }

  Match _matchFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Match(
      id: doc.id,
      userIds: List<String>.from(data['userIds'] as List),
      createdAt: _toDate(data['createdAt']),
      updatedAt: data['updatedAt'] == null ? null : _toDate(data['updatedAt']),
      lastMessage: data['lastMessage'] as String?,
    );
  }

  /// Server timestamps read back as `null` until the write is acknowledged.
  static DateTime _toDate(Object? value) =>
      value is Timestamp ? value.toDate() : DateTime.now();
}
