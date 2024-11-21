import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  List<LatLng> _routePoints = []; // 그린 경로를 저장하는 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(34.70, 135.2), // 지도 중심 좌표
          initialZoom: 13.0, // 줌 레벨 설정
          onTap: _addPointToRoute, // 지도 터치 시 경로에 좌표 추가
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints, // 그린 경로의 좌표들
                strokeWidth: 4.0,
                color: Colors.red, // 경로의 색깔
              ),
            ],
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearRoute,
        child: const Icon(Icons.clear),
      ),
    );
  }

  // TapPosition을 포함한 onTap 함수 수정
  void _addPointToRoute(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _routePoints.add(latLng); // 터치한 위치의 좌표를 경로에 추가
      print('Route points: $_routePoints');
    });
  }

  // 경로 초기화
  void _clearRoute() {
    setState(() {
      _routePoints.clear(); // 경로를 초기화
    });
  }
}
