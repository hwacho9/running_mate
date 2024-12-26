import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/location_provider.dart';
import 'package:running_mate/screens/SNS/sns_search_view.dart';
import 'package:running_mate/viewmodels/sns_view_model.dart';
import 'package:running_mate/widgets/result_minimap.dart';

class SnsView extends StatefulWidget {
  const SnsView({super.key});

  @override
  State<SnsView> createState() => _SnsViewState();
}

class _SnsViewState extends State<SnsView> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String currentRegion = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();

      // 지역 정보가 로드될 때까지 기다림
      if (locationProvider.region.isNotEmpty) {
        setState(() {
          currentRegion = locationProvider.region;
        });

        // SNS 데이터 로드
        context.read<SnsViewModel>().loadSNSData(currentRegion, userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snsViewModel = context.watch<SnsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // 검색 이모티콘
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SnsSearchView()),
              );
            },
          ),
        ],
      ),
      body: snsViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 현재 지역 러너 현황
                    Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentRegion,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '現在の地域ランナー',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${snsViewModel.currentRegionRunners} 人',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 인기 트랙
                    const Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '人気トラック',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snsViewModel.popularTracks.length,
                        itemBuilder: (context, index) {
                          final track = snsViewModel.popularTracks[index];
                          print(track);
                          return Card(
                            child: SizedBox(
                              width: 200,
                              height: 100, // Total card height
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Optional, for aesthetics
                                      child: SizedBox(
                                        height:
                                            100, // Explicit height for the map
                                        width: double
                                            .infinity, // Match the card's width
                                        child: ResultMinimap(
                                          routePoints: (track['coordinates']
                                                      as List<dynamic>?)
                                                  ?.map((point) => {
                                                        'lat': point['lat']
                                                            as double,
                                                        'lng': point['lng']
                                                            as double,
                                                      })
                                                  .toList() ??
                                              [], // Fallback to an empty list if null
                                          initialZoom: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track['name'] ?? 'Unknown',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.people,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${track['participants_count'] ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 실시간 달리는 친구들
                    const Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '走ってる友達',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: snsViewModel.runningFriends.map((friend) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(friend['nickname'] ?? 'Unknown'),
                          subtitle: Text(friend['region'] ?? 'Unknown'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
