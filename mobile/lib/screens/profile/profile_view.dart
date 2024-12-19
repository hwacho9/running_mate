import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/profile/widgets/profile_header.dart';
import 'package:running_mate/screens/profile/widgets/profile_record_page.dart';
import 'package:running_mate/screens/profile/widgets/profile_stats_page.dart';
import 'package:running_mate/screens/tracks/widgets/track_list_tile.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:running_mate/viewmodels/my_tracks_view_model.dart';
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

    final authViewModel = context.read<AuthViewModel>();
    final isMyProfile = authViewModel.user?.uid == widget.userId;

    _tabController = TabController(length: isMyProfile ? 2 : 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileViewModel = context.read<ProfileViewModel>();
      await profileViewModel.loadUserProfile(widget.userId);
      await profileViewModel.loadUserRecords(widget.userId);

      if (!isMyProfile) {
        final tracksViewModel = context.read<MyTracksViewModel>();
        await tracksViewModel.loadUserTracks(widget.userId);
      }

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
    final tracksViewModel = context.watch<MyTracksViewModel>();

    final isMyProfile = authViewModel.user?.uid == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isMyProfile)
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
            tabs: isMyProfile
                ? const [
                    Tab(text: "Stats"),
                    Tab(text: "Records"),
                  ]
                : const [
                    Tab(text: "Stats"),
                    Tab(text: "Records"),
                    Tab(text: "Tracks"),
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
                  if (!isMyProfile)
                    tracksViewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomScrollView(
                            slivers: [
                              tracksViewModel.tracks.isEmpty
                                  ? const SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(
                                        child: Text(
                                          'No routes saved yet.',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final track =
                                              tracksViewModel.tracks[index];

                                          // coordinates (List<LatLng>)를 List<Map<String, dynamic>>로 변환
                                          final routePoints = track.coordinates
                                              .map((latLng) => {
                                                    'lat': latLng.latitude,
                                                    'lng': latLng.longitude
                                                  })
                                              .toList();

                                          return TrackListTile(
                                            trackId: track.id,
                                            name: track.name,
                                            description: track.description,
                                            distance: track.distance,
                                            region: track.region ?? "",
                                            createdAt: track.createdAt ??
                                                DateTime.now(),
                                            routePoints: routePoints,
                                            participants:
                                                track.participantsCcount,
                                          );
                                        },
                                        childCount:
                                            tracksViewModel.tracks.length,
                                      ),
                                    ),
                            ],
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
