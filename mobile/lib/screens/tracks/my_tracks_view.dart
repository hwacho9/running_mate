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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyTracksViewModel>().loadUserTracks();
    });
  }

  Future<void> _refreshData() async {
    // 데이터 새로고침 함수
    await context.read<MyTracksViewModel>().loadUserTracks();
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
              Tab(text: "BOOKMARKED"),
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
                          viewModel.tracks.isEmpty
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
                                      final track = viewModel.tracks[index];

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
                                        createdAt:
                                            track.createdAt ?? DateTime.now(),
                                        routePoints: routePoints,
                                      );
                                    },
                                    childCount: viewModel.tracks.length,
                                  ),
                                ),
                        ],
                      ),
              ),
              // 두 번째 탭: BOOKMARKED
              const Center(
                child: Text('No bookmarked routes yet.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
