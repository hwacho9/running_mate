import 'package:flutter/material.dart';

class FriendListTile extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendListTile({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(friend['nickname'] ?? 'Unknown'),
      subtitle: Text(friend['region'] ?? 'Unknown'),
    );
  }
}
