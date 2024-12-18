import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/profile/widgets/profile_run_calendar.dart';
import 'package:running_mate/screens/profile/widgets/profile_stat_grid.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      profileViewModel.loadUserProfile(widget.userId);
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
    final userStats = profileViewModel.userStats;

    String? nickname = authViewModel.user?.nickname;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname!, // Replace with actual username
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Following: ${profileViewModel.followingCount}"),
                          const SizedBox(width: 16),
                          Text("Followers: ${profileViewModel.followersCount}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              padding: const EdgeInsets.all(15.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Stats & Calendar
                  profileViewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              if (userStats != null)
                                ProfileStatGrid(
                                  totalRunCount: userStats.totalRunCount,
                                  totalRunDays: userStats.totalRunDays,
                                  currentStreak: userStats.currentStreak,
                                  totalDistance: userStats.totalDistance,
                                  longestStreak: userStats.longestStreak,
                                  totalTime: userStats.totalTime,
                                  lastRunDate: userStats.lastRunDate!.toDate(),
                                ),
                              const SizedBox(height: 5),
                              ProfileRunCalendar(
                                  runDates: profileViewModel.runDates),
                            ],
                          ),
                        ),
                  // Tab 2: Records
                  const Center(child: Text("Record list here")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
