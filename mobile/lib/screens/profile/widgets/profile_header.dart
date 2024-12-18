import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String nickname;
  final int followingCount;
  final int followersCount;

  const ProfileHeader({
    super.key,
    required this.nickname,
    required this.followingCount,
    required this.followersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Following: $followingCount"),
                    const SizedBox(width: 16),
                    Text("Followers: $followersCount"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
