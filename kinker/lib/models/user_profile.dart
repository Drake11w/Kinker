/// Public profile shown on cards and in matches.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    this.bio = '',
    this.interests = const [],
    this.photoUrl,
  });

  static const int minimumAge = 18;

  final String uid;
  final String name;
  final int age;
  final String bio;
  final List<String> interests;

  /// Either an `http(s)` URL or a bundled `assets/` path.
  final String? photoUrl;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? bio,
    List<String>? interests,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'bio': bio,
        'interests': interests,
        'photoUrl': photoUrl,
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      bio: map['bio'] as String? ?? '',
      interests: List<String>.from(map['interests'] as List? ?? const []),
      photoUrl: map['photoUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.uid == uid &&
      other.name == name &&
      other.age == age &&
      other.bio == bio &&
      other.photoUrl == photoUrl &&
      _listEquals(other.interests, interests);

  @override
  int get hashCode =>
      Object.hash(uid, name, age, bio, photoUrl, Object.hashAll(interests));
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
