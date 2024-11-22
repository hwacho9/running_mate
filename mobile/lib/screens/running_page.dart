import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RunningPage extends StatefulWidget {
  final List<LatLng> routePoints;
  final List<Map<String, dynamic>> userRecords;

  const RunningPage({
    super.key,
    required this.routePoints,
    required this.userRecords,
  });

  @override
  _RunningPageState createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  LatLng? _currentPosition; // 내 현재 위치
  int _timeElapsed = 0; // 경과 시간
  final Map<String, LatLng> _userPositions = {}; // 다른 유저들의 현재 위치
  late Timer _timer; // 경과 시간 타이머

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // 위치 권한 확인 및 요청
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
            'Location permissions are permanently denied. Cannot access location.',
          ),
        ),
      );
      return;
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // 위치 실시간 추적
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
        _updateUserPositions();
      });
    });
  }

  void _updateUserPositions() {
    for (var user in widget.userRecords) {
      final coordinates = user['coordinates'] as List;
      for (var i = 0; i < coordinates.length - 1; i++) {
        final current = coordinates[i];
        final next = coordinates[i + 1];

        if (current['time'] <= _timeElapsed && _timeElapsed < next['time']) {
          final progress = (_timeElapsed - current['time']) /
              (next['time'] - current['time']);

          final lat =
              current['lat'] + (next['lat'] - current['lat']) * progress;
          final lng =
              current['lng'] + (next['lng'] - current['lng']) * progress;

          setState(() {
            _userPositions[user['userName']] = LatLng(lat, lng);
          });
        }
      }
    }
  }

  String _calculateRanking() {
    if (_currentPosition == null) return "Calculating...";
    final distances = <String, double>{};

    for (var user in widget.userRecords) {
      final name = user['userName'];
      final position = _userPositions[name];
      if (position != null) {
        distances[name] = _calculateDistance(position, widget.routePoints.last);
      }
    }

    distances["You"] =
        _calculateDistance(_currentPosition!, widget.routePoints.last);

    final sorted = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final ranking = sorted.indexWhere((entry) => entry.key == "You") + 1;
    return "Your Rank: $ranking / ${sorted.length}";
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance(p1, p2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Running...")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition ?? widget.routePoints.first,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // 경로 표시
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                // 내 위치 표시
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.run_circle,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                // 다른 유저 위치 표시
                for (var user in _userPositions.entries)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: user.value,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.person,
                          color: Colors.green,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _calculateRanking(),
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
