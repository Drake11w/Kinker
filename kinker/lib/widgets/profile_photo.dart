import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Resolves a profile's photo, or `null` when it has none.
ImageProvider? profileImage(UserProfile profile) {
  final url = profile.photoUrl;
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }
  return AssetImage(url);
}

/// Stable per-user gradient used when a profile has no photo.
LinearGradient profileGradient(UserProfile profile) {
  final hue = (profile.uid.hashCode % 360).abs().toDouble();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor(),
      HSLColor.fromAHSL(1, (hue + 40) % 360, 0.6, 0.3).toColor(),
    ],
  );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.radius = 24});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final image = profileImage(profile);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: image == null ? profileGradient(profile) : null,
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(
              profile.initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
