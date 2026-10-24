import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'profile_photo.dart';

/// Full-size card shown in the swipe deck.
class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final image = profileImage(profile);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image(image: image, fit: BoxFit.cover)
          else
            DecoratedBox(
              decoration: BoxDecoration(gradient: profileGradient(profile)),
              child: Center(
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
                if (profile.interests.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final interest in profile.interests)
                        Chip(
                          label: Text(interest),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
