import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/screens/running/running_result_view.dart';
import 'package:running_mate/utils/direction_util.dart';

class RunningView extends StatefulWidget {
  const RunningView({super.key});

  @override
  _RunningViewState createState() => _RunningViewState();
}

class _RunningViewState extends State<RunningView> {
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSubscription;
  List<Map<String, dynamic>> _coordinates = []; // 시간, 위치 저장
  LatLng? _currentPosition;
  LatLng? _previousPosition;
  double _totalDistance = 0.0; // 이동한 거리
  double _heading = 0.0; // 방향 값 저장
  Timer? _coordinateTimer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startTime = DateTime.now(); // 시작 시간 기록
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);

        _heading = position.heading; // 방향 값 업데이트

        if (_previousPosition != null) {
          final distance = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          _totalDistance += distance;
        }
        _previousPosition = _currentPosition;
      });
      _mapController.move(_currentPosition!, 15.0);
    });

    // 3초마다 좌표 저장
    _coordinateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPosition != null) {
        _coordinates.add({
          'time': DateTime.now().toIso8601String(),
          'lat': _currentPosition!.latitude,
          'lng': _currentPosition!.longitude,
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _coordinateTimer?.cancel();
    super.dispose();
  }

  void _onFinish() {
    final endTime = DateTime.now();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RunningResultView(
          startTime: _startTime!,
          endTime: endTime,
          coordinates: _coordinates,
          totalDistance: _totalDistance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ?? LatLng(34.70, 135.2),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _coordinates
                    .map((coord) =>
                        LatLng(coord['lat'] as double, coord['lng'] as double))
                    .toList(),
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
                  child: Transform.rotate(
                    angle: DirectionUtil.headingToRadians(_heading), // 방향 적용
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFinish, // 완료 버튼 클릭
        child: const Icon(Icons.check),
      ),
    );
  }
}
