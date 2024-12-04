import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'running_page.dart';

class RouteDetailPage extends StatelessWidget {
  final String routeName;
  final List<LatLng> routePoints;

  const RouteDetailPage({
    super.key,
    required this.routeName,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    final mockUserRecords = [
      {
        "userName": "User A",
        "coordinates": [
          {"time": 0, "lat": 34.689047, "lng": 135.181125},
          {"time": 120, "lat": 34.690636, "lng": 135.184093},
          {"time": 240, "lat": 34.692227, "lng": 135.187111},
          {"time": 360, "lat": 34.69289, "lng": 135.190108},
          {"time": 480, "lat": 34.693986, "lng": 135.19228},
          {"time": 600, "lat": 34.695141, "lng": 135.194665},
        ],
      },
      {
        "userName": "User B",
        "coordinates": [
          {"time": 0, "lat": 34.689047, "lng": 135.181125},
          {"time": 180, "lat": 34.690636, "lng": 135.184093},
          {"time": 360, "lat": 34.692227, "lng": 135.187111},
          {"time": 540, "lat": 34.69289, "lng": 135.190108},
          {"time": 720, "lat": 34.693986, "lng": 135.19228},
          {"time": 900, "lat": 34.695141, "lng": 135.194665},
        ],
      },
      {
        "userName": "User C",
        "coordinates": [
          {"time": 0, "lat": 34.689047, "lng": 135.181125},
          {"time": 240, "lat": 34.690636, "lng": 135.184093},
          {"time": 480, "lat": 34.692227, "lng": 135.187111},
          {"time": 720, "lat": 34.69289, "lng": 135.190108},
          {"time": 960, "lat": 34.693986, "lng": 135.19228},
          {"time": 1200, "lat": 34.695141, "lng": 135.194665},
        ],
      },
    ];

    // 각 사용자 완주 시간 계산
    // 각 사용자 완주 시간 계산
    final rankings = mockUserRecords.map((user) {
      // 사용자 이름과 좌표 가져오기
      final userName = user['userName'] as String;
      final coordinates = user['coordinates'] as List<dynamic>;

      // 마지막 좌표의 시간 가져오기
      final lastPoint = coordinates.last as Map<String, dynamic>;
      final totalTime = lastPoint['time'] as int;

      // 시간 형식으로 변환
      final minutes = totalTime ~/ 60;
      final seconds = totalTime % 60;
      final timeString =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return '$userName - $timeString';
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    routePoints.isNotEmpty ? routePoints.first : LatLng(0, 0),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Participants: 3',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Ranking:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  rankings.join('\n'),
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // 경주 시작: RunningPage로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RunningPage(
                            routePoints: routePoints,
                            userRecords: mockUserRecords,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Running'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
