import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  List<LatLng> _routePoints = []; // 경로 저장

  void _saveRoute() {
    if (_routePoints.isEmpty) return;

    // Navigate to MyRoutesPage with the new route
    Navigator.pushNamed(context, '/my-routes', arguments: _routePoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Your Route'),
        actions: [
          IconButton(
            onPressed: _saveRoute,
            icon: const Icon(Icons.save),
            tooltip: 'Save Route',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(34.70, 135.2), // 지도 중심 좌표
          initialZoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              print('Tapped at $latLng');
              _routePoints.add(latLng);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: Colors.red,
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

  // // TapPosition을 포함한 onTap 함수 수정
  // void _addPointToRoute(TapPosition tapPosition, LatLng latLng) {
  //   setState(() {
  //     _routePoints.add(latLng); // 터치한 위치의 좌표를 경로에 추가
  //     print('Route points: $_routePoints');
  //   });
  // }

  // 경로 초기화
  void _clearRoute() {
    setState(() {
      _routePoints.clear(); // 경로를 초기화
    });
  }
}
