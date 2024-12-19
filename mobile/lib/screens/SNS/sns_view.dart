import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';
import 'package:running_mate/viewmodels/sns_view_model.dart';

//TODO
// Streambuilder로 현재 달리는 유저수, 달리는 친구들을 실시간으로 업데이트

class SnsView extends StatefulWidget {
  const SnsView({super.key});

  @override
  State<SnsView> createState() => _SnsViewState();
}

class _SnsViewState extends State<SnsView> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentRegion = await _getRegionFromLocation();
      print(currentRegion);
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
                            const Text(
                              '현재 달리는 중',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${snsViewModel.currentRegionRunners} 러너',
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
                    const Text(
                      '인기 트랙',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snsViewModel.popularTracks.length,
                        itemBuilder: (context, index) {
                          final track = snsViewModel.popularTracks[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track['name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${track['participants_count'] ?? 0} 명 참여',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 실시간 달리는 친구들
                    const Text(
                      '달리는 친구들',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
