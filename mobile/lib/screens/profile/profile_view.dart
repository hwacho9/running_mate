import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/profile/widgets/profile_run_calendar.dart';
import 'package:running_mate/screens/profile/widgets/profile_stat_grid.dart';
import 'package:running_mate/screens/profile/widgets/record_list_tile.dart';
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
      profileViewModel.loadUserRecords(widget.userId);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname ?? 'User',
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
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Stats & Calendar
                profileViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            (userStats != null)
                                ? ProfileStatGrid(
                                    totalRunCount: userStats.totalRunCount,
                                    totalRunDays: userStats.totalRunDays,
                                    currentStreak: userStats.currentStreak,
                                    totalDistance: userStats.totalDistance,
                                    longestStreak: userStats.longestStreak,
                                    totalTime: userStats.totalTime,
                                    lastRunDate:
                                        userStats.lastRunDate!.toDate(),
                                  )
                                : ProfileStatGrid(
                                    totalRunCount: 0,
                                    totalRunDays: 0,
                                    longestStreak: 0,
                                    currentStreak: 0,
                                    totalDistance: 0,
                                    totalTime: 0,
                                    lastRunDate: DateTime.now(),
                                  ),
                            const SizedBox(height: 16),
                            ProfileRunCalendar(
                              runDates: profileViewModel.runDates,
                            ),
                          ],
                        ),
                      ),
                // Tab 2: Records
                profileViewModel.isLoadingRecords
                    ? const Center(child: CircularProgressIndicator())
                    : profileViewModel.userRecords.isEmpty
                        ? const Center(
                            child: Text(
                              '記録なし',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: profileViewModel.userRecords.length,
                            itemBuilder: (context, index) {
                              final record =
                                  profileViewModel.userRecords[index];
                              final startTime =
                                  record['start_time']?.toDate() ??
                                      DateTime.now();
                              final formattedStartTime =
                                  DateFormat('yyyy-MM-dd HH:mm')
                                      .format(startTime);

                              return RecordListTile(
                                trackId: record['track_id'] ?? 'Unknown',
                                name: formattedStartTime,
                                distance: record['distance'] ?? 0.0,
                                region: record['region'] ?? 'Unknown',
                                createdAt: startTime,
                                routePoints: (record['coordinates']
                                        as List<dynamic>)
                                    .map((coord) =>
                                        Map<String, dynamic>.from(coord))
                                    .toList(), // Ensure proper type conversion
                              );
                            },
                          )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
