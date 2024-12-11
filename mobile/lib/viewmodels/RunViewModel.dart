// viewmodels/run_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/run_service.dart';

class RunViewModel extends ChangeNotifier {
  final RunService _runService;

  RunViewModel(this._runService);

  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;

  List<LatLng> get routePoints => _routePoints;
  LatLng? get currentPosition => _currentPosition;

  // 아래 값들은 실제 비즈니스 로직에 따라 설정하거나
  // 외부로부터 주입받을 수 있습니다.
  String name = "MyTrack";
  String creatorId = ""; // 로그인된 사용자 UID를 나중에 설정
  String description = "Test Description";
  String region = "Seoul";
  double distance = 0.0;

  Future<void> init(String creatorId) async {
    this.creatorId = creatorId; // 로그인된 사용자의 UID 설정
    await _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 서비스 비활성화 상태 처리 (UI에서 Snackbar 처리 가능)
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 거부 상태 처리
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한 영구 거부 상태 처리
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();

    Geolocator.getPositionStream().listen((Position pos) {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
    });
  }

  void addRoutePoint(LatLng point) {
    _routePoints.add(point);
    // 거리 계산 로직 추가 가능 (예: 마지막 포인트와의 거리 계산하여 distance 업데이트)
    notifyListeners();
  }

  Future<bool> saveRoute() async {
    if (_routePoints.isEmpty) return false;

    await _runService.saveTrack(
      name: name,
      creatorId: creatorId,
      description: description,
      region: region,
      distance: distance,
      coordinates: _routePoints,
    );
    _routePoints.clear();
    notifyListeners();
    return true;
  }

  void clearRoute() {
    _routePoints.clear();
    notifyListeners();
  }
}
