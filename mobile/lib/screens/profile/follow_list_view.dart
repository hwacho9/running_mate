import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/profile/profile_view.dart';
import 'package:running_mate/viewmodels/follow_list_view_model.dart';
import 'package:running_mate/viewmodels/profile_view_model.dart';

class FollowListView extends StatefulWidget {
  final String userId; // 사용자 ID

  const FollowListView({
    super.key,
    required this.userId,
  });

  @override
  State<FollowListView> createState() => _FollowListViewState();
}

class _FollowListViewState extends State<FollowListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<FollowListViewModel>();
      viewModel.loadFollowing(widget.userId);
      viewModel.loadFollowers(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FollowListViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Follow List"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Following"),
            Tab(text: "Followers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowList(
              viewModel.following, "No following users.", profileViewModel),
          _buildFollowList(
              viewModel.followers, "No followers.", profileViewModel),
        ],
      ),
    );
  }

  Widget _buildFollowList(List<Map<String, dynamic>> users, String emptyMessage,
      ProfileViewModel profileViewModel) {
    if (users.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: FutureBuilder<String?>(
            future: profileViewModel.fetchNickname(user['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading...");
              } else if (snapshot.hasError) {
                return const Text("Error fetching nickname");
              } else {
                return Text(snapshot.data ?? "Unknown");
              }
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileView(
                  userId: user['id'],
                ),
              ),
            );
            // Navigate to user profile
            print("Navigate to ${user['nickname']}'s profile");
          },
        );
      },
    );
  }
}
