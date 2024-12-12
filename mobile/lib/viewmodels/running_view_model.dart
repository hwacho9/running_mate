// running_viewmodel.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RunningViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _coordinates = []; // 시간, 위치 저장
  LatLng? _currentPosition;
  LatLng? _previousPosition;
  double _totalDistance = 0.0; // 이동한 거리
  double _heading = 0.0; // 방향 값 저장
  DateTime? _startTime;
  StreamSubscription<Position>? _positionSubscription; // 스트림 구독 관리
  Timer? _coordinateTimer; // 타이머 관리
  bool _isTracking = false; // 추적 상태
  bool _isPaused = false; // 일시정지 상태

  DateTime? _pauseStartTime; // 일시정지 시작 시간
  Duration _totalPauseTime = Duration.zero; // 총 일시정지 시간

  List<Map<String, dynamic>> get coordinates => _coordinates;
  LatLng? get currentPosition => _currentPosition;
  double get totalDistance => _totalDistance;
  double get heading => _heading;
  DateTime? get startTime => _startTime;
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  Duration get totalPauseTime => _totalPauseTime;

  Future<void> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화 상태입니다.');
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
  }

  Future<void> startTracking() async {
    try {
      await checkPermissions();

      // 초기 위치 가져오기
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition =
          LatLng(initialPosition.latitude, initialPosition.longitude);
      _previousPosition = _currentPosition;
      _heading = initialPosition.heading;
      notifyListeners();

      _startTime = DateTime.now(); // 시작 시간 기록
      _isTracking = true;
      notifyListeners();

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((Position position) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _heading = position.heading;

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
        notifyListeners();
      }, onError: (error) {
        print('Error in position stream: $error');
        stopTracking();
      });

      // 3초마다 좌표 저장
      _coordinateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_currentPosition != null) {
          if (_coordinates.isEmpty ||
              DateTime.now()
                      .difference(DateTime.parse(_coordinates.last['time']))
                      .inSeconds >=
                  3) {
            _coordinates.add({
              'time': DateTime.now().toIso8601String(),
              'lat': _currentPosition!.latitude,
              'lng': _currentPosition!.longitude,
            });
            notifyListeners();
          }
        }
      });
    } catch (e) {
      print('Tracking error: $e');
      stopTracking();
    }
  }

  void pauseTracking() {
    if (_isTracking && !_isPaused) {
      _isPaused = true;
      _pauseStartTime = DateTime.now();
      _positionSubscription?.pause();
      _coordinateTimer?.cancel();
      notifyListeners();
    }
  }

  void resumeTracking() {
    if (_isPaused) {
      if (_pauseStartTime != null) {
        _totalPauseTime += DateTime.now().difference(_pauseStartTime!);
      }
      _isPaused = false;
      _pauseStartTime = null;
      _positionSubscription?.resume();
      _coordinateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_currentPosition != null) {
          if (_coordinates.isEmpty ||
              DateTime.now()
                      .difference(DateTime.parse(_coordinates.last['time']))
                      .inSeconds >=
                  3) {
            _coordinates.add({
              'time': DateTime.now().toIso8601String(),
              'lat': _currentPosition!.latitude,
              'lng': _currentPosition!.longitude,
            });
            notifyListeners();
          }
        }
      });
      notifyListeners();
    }
  }

  void stopTracking() {
    if (_pauseStartTime != null) {
      _totalPauseTime += DateTime.now().difference(_pauseStartTime!);
    }
    _positionSubscription?.cancel();
    _coordinateTimer?.cancel();
    _positionSubscription = null;
    _coordinateTimer = null;
    _isTracking = false;
    _isPaused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking(); // 추적 종료 처리
    super.dispose();
  }
}
