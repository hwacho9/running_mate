import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/tracks/widgets/track_list_tile.dart';
import 'package:running_mate/viewmodels/my_tracks_view_model.dart';

class MyTracksView extends StatefulWidget {
  const MyTracksView({super.key});

  @override
  State<MyTracksView> createState() => _MyTracksViewState();
}

class _MyTracksViewState extends State<MyTracksView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyTracksViewModel>().loadUserTracks(_auth.currentUser!.uid);
    });
  }

  Future<void> _refreshData() async {
    // 데이터 새로고침 함수
    await context
        .read<MyTracksViewModel>()
        .loadUserTracks(_auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyTracksViewModel>();

    return DefaultTabController(
      length: 2, // Tab 개수 설정
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Tracks'),
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.red,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "My Tracks"),
              Tab(text: "Participated"),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          child: TabBarView(
            children: [
              // 첫 번째 탭: My Tracks
              RefreshIndicator(
                onRefresh: _refreshData,
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomScrollView(
                        slivers: [
                          viewModel.myTracks.isEmpty
                              ? const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      'トラックがありません.',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final track = viewModel.myTracks[index];

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
                                        createdAt:
                                            track.createdAt ?? DateTime.now(),
                                        routePoints: routePoints,
                                        participants: track.participantsCcount,
                                      );
                                    },
                                    childCount: viewModel.myTracks.length,
                                  ),
                                ),
                        ],
                      ),
              ),
              // 두 번째 탭: Participated
              RefreshIndicator(
                onRefresh: _refreshData,
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomScrollView(
                        slivers: [
                          viewModel.participatedTracks.isEmpty
                              ? const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      '参加したトラックがありません.',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final track =
                                          viewModel.participatedTracks[index];

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
                                        createdAt:
                                            track.createdAt ?? DateTime.now(),
                                        routePoints: routePoints,
                                        participants: track.participantsCcount,
                                      );
                                    },
                                    childCount:
                                        viewModel.participatedTracks.length,
                                  ),
                                ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
