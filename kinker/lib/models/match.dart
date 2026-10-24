/// A mutual like between two users. Its [id] is deterministic so both
/// sides resolve to the same document.
class Match {
  const Match({
    required this.id,
    required this.userIds,
    required this.createdAt,
    this.lastMessage,
    this.updatedAt,
  });

  final String id;
  final List<String> userIds;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? updatedAt;

  static String idFor(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  String otherUserId(String myUid) =>
      userIds.firstWhere((id) => id != myUid, orElse: () => myUid);

  DateTime get sortTime => updatedAt ?? createdAt;

  Match copyWith({String? lastMessage, DateTime? updatedAt}) {
    return Match(
      id: id,
      userIds: userIds,
      createdAt: createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
