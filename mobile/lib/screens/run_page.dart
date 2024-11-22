import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 변환을 위해 필요

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  List<LatLng> _routePoints = []; // 경로 저장

  // 경로 저장 함수
  Future<void> _saveRoute() async {
    if (_routePoints.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // 기존 저장된 경로 가져오기
    final existingRoutes = prefs.getStringList('routes') ?? [];

    // 새로운 경로 생성
    final newRoute = {
      'name': 'Route ${existingRoutes.length + 1}', // 경로 이름
      'points': _routePoints
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
    };

    // 기존 경로에 새 경로 추가
    existingRoutes.add(jsonEncode(newRoute));

    // 저장
    await prefs.setStringList('routes', existingRoutes);

    // 저장 후 알림 및 초기화
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route saved successfully!')),
    );

    setState(() {
      _routePoints.clear();
    });

    // My Routes 페이지로 이동
    Navigator.pushNamed(context, '/my-routes');
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
          initialCenter: LatLng(34.70, 135.2),
          initialZoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              print(latLng);
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearRoute,
        child: const Icon(Icons.clear),
      ),
    );
  }

  // 경로 초기화
  void _clearRoute() {
    setState(() {
      _routePoints.clear();
    });
  }
}
