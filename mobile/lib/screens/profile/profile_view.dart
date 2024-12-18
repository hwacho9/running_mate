import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/profile/widgets/profile_header.dart';
import 'package:running_mate/screens/profile/widgets/profile_record_page.dart';
import 'package:running_mate/screens/profile/widgets/profile_stats_page.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:running_mate/viewmodels/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  const ProfileView({super.key, required this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileViewModel = context.read<ProfileViewModel>();
      final authViewModel = context.read<AuthViewModel>();

      await profileViewModel.loadUserProfile(widget.userId);
      await profileViewModel.loadUserRecords(widget.userId);
      await profileViewModel.checkFollowingStatus(
          authViewModel.user?.uid ?? '', widget.userId);

      // 닉네임 가져오기
      final nickname = await profileViewModel.fetchNickname(widget.userId);
      setState(() {
        _nickname = nickname;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (authViewModel.user?.uid == widget.userId) // 조건부 렌더링
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authViewModel.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginView()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          ProfileHeader(
            nickname: _nickname ?? 'User',
            followingCount: profileViewModel.followingCount,
            followersCount: profileViewModel.followersCount,
            currentUserId: authViewModel.user?.uid ?? '',
            profileUserId: widget.userId,
            isFollowing: profileViewModel.isFollowing,
          ),
          const Divider(),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Stats"),
              Tab(text: "Records"),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProfileStatsPage(
                    isLoading: profileViewModel.isLoading,
                    userStats: profileViewModel.userStats,
                    runDates: profileViewModel.runDates,
                  ),
                  ProfileRecordsPage(
                    isLoadingRecords: profileViewModel.isLoadingRecords,
                    userRecords: profileViewModel.userRecords,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
