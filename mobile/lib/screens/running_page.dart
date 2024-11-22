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

class _RunningPageState extends State<RunningPage>
    with TickerProviderStateMixin {
  LatLng? _currentPosition;
  int _timeElapsed = 0; // 경과 시간 (초)
  final Map<String, LatLng> _userPositions = {};
  late Timer _timer;
  String? _overtakeMessage; // 추월 메시지
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

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
    final previousRankings = _calculateRankings(); // 이전 랭킹 저장

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

    final newRankings = _calculateRankings(); // 새로운 랭킹 계산
    _checkForOvertake(previousRankings, newRankings); // 추월 여부 확인
  }

  void _checkForOvertake(
      List<String> previousRankings, List<String> newRankings) {
    final previousIndex =
        previousRankings.indexWhere((rank) => rank.contains("You"));
    final newIndex = newRankings.indexWhere((rank) => rank.contains("You"));

    if (newIndex < previousIndex) {
      // 내가 다른 유저를 추월했을 경우
      _showOverlayMessage("追い越しました !");
    } else if (newIndex > previousIndex) {
      // 다른 유저가 나를 추월했을 경우
      _showOverlayMessage("追い越されました!");
    }
  }

  void _showOverlayMessage(String message) {
    setState(() {
      _overtakeMessage = message;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 메시지 애니메이션 시작
    _animationController!.forward();

    // 일정 시간 후 메시지 제거
    Future.delayed(const Duration(seconds: 2), () {
      _animationController!.reverse().then((value) {
        setState(() {
          _overtakeMessage = null;
        });
      });
    });
  }

  List<String> _calculateRankings() {
    if (_currentPosition == null) return ["Calculating..."];

    final distances = <String, double>{};

    // 다른 사용자 거리 계산
    for (var user in widget.userRecords) {
      final name = user['userName'];
      final position = _userPositions[name];
      if (position != null) {
        distances[name] = _calculateDistance(position, widget.routePoints.last);
      }
    }

    // 내 거리 계산
    distances["You"] =
        _calculateDistance(_currentPosition!, widget.routePoints.last);

    // 거리 기준 정렬 및 랭킹 계산
    final sorted = distances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final totalParticipants = sorted.length;

    return List.generate(
      sorted.length,
      (index) {
        final isYou = sorted[index].key == "You";
        final rankText = "${index + 1}등: ${sorted[index].key}";
        final ratioText = " (${index + 1}/$totalParticipants)";
        return isYou ? "$rankText$ratioText" : rankText;
      },
    );
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance(p1, p2);
  }

  double _calculateProgress(LatLng position) {
    if (position == null) return 0.0;
    final totalDistance =
        _calculateDistance(widget.routePoints.first, widget.routePoints.last);
    final traveledDistance =
        _calculateDistance(widget.routePoints.first, position);
    return traveledDistance / totalDistance;
  }

  String _getRunningTime() {
    final minutes = _timeElapsed ~/ 60;
    final seconds = _timeElapsed % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  String _getRunningPace() {
    if (_currentPosition == null || _timeElapsed == 0) return "Calculating...";
    final distance =
        _calculateDistance(widget.routePoints.first, _currentPosition!);
    final pace = _timeElapsed / (distance / 1000); // 초/킬로미터
    final minutes = pace ~/ 60;
    final seconds = (pace % 60).toInt();
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km";
  }

  @override
  Widget build(BuildContext context) {
    final progressMarkers = <Widget>[];

    // 내 위치 마커 추가
    if (_currentPosition != null) {
      progressMarkers.add(Positioned(
        left: MediaQuery.of(context).size.width *
            _calculateProgress(_currentPosition!),
        child: const Icon(Icons.run_circle, color: Colors.red, size: 16),
      ));
    }

    // 다른 유저들의 위치 마커 추가
    for (var user in _userPositions.entries) {
      progressMarkers.add(Positioned(
        left:
            MediaQuery.of(context).size.width * _calculateProgress(user.value),
        child: Icon(Icons.person, color: Colors.green, size: 16),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Running...")),
      body: Stack(
        children: [
          Column(
            children: [
              // 지도 영역
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition ?? widget.routePoints.first,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: widget.routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blueAccent,
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
                              Icons.run_circle,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
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
              // 진행률 바
              Stack(
                children: [
                  Container(
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  ...progressMarkers,
                ],
              ),
              // 실시간 랭킹
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "러닝 시간: ${_getRunningTime()}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "러닝 페이스: ${_getRunningPace()}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        "Ranking:",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ..._calculateRankings().map(
                        (rank) => Text(
                          rank,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_overtakeMessage != null)
            Center(
              child: AnimatedOpacity(
                opacity: _overtakeMessage != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _overtakeMessage!,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
