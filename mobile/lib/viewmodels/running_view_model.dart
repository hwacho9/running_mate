import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/running_status_provider.dart';

class RunningViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _coordinates = []; // 시간, 위치 저장
  LatLng? _currentPosition;
  LatLng? _previousPosition;
  double _totalDistance = 0.0; // 이동한 거리
  double _heading = 0.0; // 방향 값 저장
  DateTime? _startTime;
  StreamSubscription<Position>? _positionSubscription; // 스트림 구독 관리
  Timer? _coordinateTimer; // 타이머 관리

  DateTime? _pauseStartTime; // 일시정지 시작 시간
  Duration _totalPauseTime = Duration.zero; // 총 일시정지 시간

  List<Map<String, dynamic>> get coordinates => _coordinates;
  LatLng? get currentPosition => _currentPosition;
  double get totalDistance => _totalDistance;
  double get heading => _heading;
  DateTime? get startTime => _startTime;
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

  Future<void> startTracking(BuildContext context) async {
    final statusProvider =
        Provider.of<RunningStatusProvider>(context, listen: false);

    // 이미 실행 중인 경우 중단
    if (_positionSubscription != null || _coordinateTimer != null) {
      print('Tracking already started');
      return;
    }

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
      statusProvider.startRunning(); // 상태 업데이트

      // 위치 스트림 설정
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((position) {
        if (!statusProvider.isRunning) return; // isRunning이 false이면 업데이트 중단
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
      });

      // 3초마다 좌표 저장
      _coordinateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!statusProvider.isRunning) return; // isRunning이 false이면 업데이트 중단
        if (statusProvider.isPaused) return; // isPaused가 true 업데이트 중단
        if (_currentPosition != null &&
            (_coordinates.isEmpty ||
                DateTime.now()
                        .difference(DateTime.parse(_coordinates.last['time']))
                        .inSeconds >=
                    3)) {
          _coordinates.add({
            'time': DateTime.now().toIso8601String(),
            'lat': _currentPosition!.latitude,
            'lng': _currentPosition!.longitude,
          });
          notifyListeners();
        }
      });
    } catch (e) {
      print('Tracking error: $e');
      stopTracking(context);
    }
  }

  void pauseTracking(BuildContext context) {
    final statusProvider =
        Provider.of<RunningStatusProvider>(context, listen: false);

    if (_pauseStartTime == null) {
      _pauseStartTime = DateTime.now(); // 일시정지 시작 시간 기록
    }

    _positionSubscription?.pause(); // 위치 업데이트 중지
    _coordinateTimer?.cancel(); // 타이머 중지
    statusProvider.pauseRunning(); // 상태 업데이트
    notifyListeners();
  }

  void resumeTracking(BuildContext context) {
    final statusProvider =
        Provider.of<RunningStatusProvider>(context, listen: false);

    if (_pauseStartTime != null) {
      _totalPauseTime +=
          DateTime.now().difference(_pauseStartTime!); // 일시정지 시간 계산
      _pauseStartTime = null; // 초기화
    }

    _positionSubscription?.resume(); // 위치 업데이트 재개
    _coordinateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!statusProvider.isRunning) return; // isRunning이 false이면 업데이트 중단
      if (statusProvider.isPaused) return; // isPaused가 true 업데이트 중단
      if (_currentPosition != null &&
          (_coordinates.isEmpty ||
              DateTime.now()
                      .difference(DateTime.parse(_coordinates.last['time']))
                      .inSeconds >=
                  3)) {
        _coordinates.add({
          'time': DateTime.now().toIso8601String(),
          'lat': _currentPosition!.latitude,
          'lng': _currentPosition!.longitude,
        });
        notifyListeners();
      }
    });
    statusProvider.resumeRunning(); // 상태 업데이트
    notifyListeners();
  }

  Future<void> stopTracking(BuildContext context) async {
    final statusProvider =
        Provider.of<RunningStatusProvider>(context, listen: false);

    // 타이머와 스트림 구독 해제
    _coordinateTimer?.cancel();
    _positionSubscription?.cancel();

    // 비동기 작업이 필요한 경우 처리
    await Future.delayed(Duration(milliseconds: 100)); // 예시로 딜레이 추가

    // 데이터 초기화
    _coordinates.clear();
    _currentPosition = null;
    _previousPosition = null;
    _totalDistance = 0.0;
    _heading = 0.0;
    _startTime = null;
    _pauseStartTime = null;
    _totalPauseTime = Duration.zero;

    // 런닝 상태 종료 및 상태 초기화
    _coordinateTimer = null;
    _positionSubscription = null;

    // 런닝 상태 종료
    statusProvider.stopRunning();

    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _coordinateTimer?.cancel();
    super.dispose();
  }
}
