import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentRegion = await _getRegionFromLocation();
      print("current region  ${currentRegion}");
      setState(() {
        this.currentRegion = currentRegion ?? 'Unknown';
      });
      context.read<SnsViewModel>().loadSNSData(currentRegion!, userId!);
    });
  }

  Future<String?> _getRegionFromLocation() async {
    try {
      // 위치 권한 요청
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다.');
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 위치를 기반으로 지역 정보를 반환 (예: Firestore와 연동하여 변환)
      // 예시: Firestore에 저장된 지역 정보와 비교
      final _region = await RegionHelper.getRegionFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final translatedRegion = CheckLanguageUtil.isKoreanRegion(_region)
          ? convertKoreanToJapanese(_region)
          : _region;

      return translatedRegion;
    } catch (e) {
      print("위치 정보 오류: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final snsViewModel = context.watch<SnsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS'),
        automaticallyImplyLeading: false,
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
                          '달리는 친구들',
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
