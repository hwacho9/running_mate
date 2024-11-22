import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  List<LatLng> _routePoints = []; // 경로 저장
  LatLng? _currentPosition; // 현재 위치
  late final MapController _mapController; // 지도 컨트롤러

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // 지도 컨트롤러 초기화
    _requestLocationPermission();
  }

  // 위치 권한 요청 및 현재 위치 가져오기
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    // 위치 권한 상태 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, cannot access location.',
          ),
        ),
      );
      return;
    }

    // 권한이 허용되었으면 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      // 지도 중심을 현재 위치로 이동
      _mapController.move(_currentPosition!, 13.0);
    });

    // 실시간 위치 업데이트
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

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
        mapController: _mapController, // 지도 컨트롤러 연결
        options: MapOptions(
          initialCenter:
              _currentPosition ?? LatLng(34.70, 135.2), // 현재 위치 또는 기본 중심
          initialZoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              _routePoints.add(latLng);
            });
            print('Route Points: $_routePoints');
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
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 30,
                  ),
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
