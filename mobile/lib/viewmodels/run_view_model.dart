import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';
import '../services/track_service.dart';

class RunViewModel extends ChangeNotifier {
  Trackservice _runService;

  RunViewModel(this._runService);

  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  String _region = "";
  double _distance = 0.0;

  List<LatLng> get routePoints => _routePoints;
  LatLng? get currentPosition => _currentPosition;
  String get region => _region;
  double get distance => _distance;

  String name = "MyTrack";
  String creatorId = "";
  String description = "Test Description";

  Future<void> init(String creatorId) async {
    this.creatorId = creatorId;

    await _requestLocationPermission();
    if (_currentPosition != null) {
      _routePoints.add(_currentPosition!); // 초기 위치를 경로에 추가
      await _updateRegion(); // 첫 번째 경로 좌표를 기반으로 지역 정보 업데이트
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
    if (_routePoints.isEmpty) {
      // 첫 번째 포인트 추가 시 지역 정보 업데이트
      _routePoints.add(point);
      _updateRegion(); // 첫 번째 좌표 기반으로 지역 정보 업데이트
    } else {
      // 두 번째 이후 포인트부터 거리 계산
      final Distance distanceCalc = Distance();
      final lastPoint = _routePoints.last;
      final double segmentDistance = distanceCalc(
        LatLng(lastPoint.latitude, lastPoint.longitude),
        LatLng(point.latitude, point.longitude),
      );
      _distance += segmentDistance;
      _routePoints.add(point);
    }

    notifyListeners();
  }

  Future<void> _updateRegion() async {
    if (_routePoints.isEmpty) return;

    final firstPoint = _routePoints.first;

    final region = await RegionHelper.getRegionFromCoordinates(
      firstPoint.latitude,
      firstPoint.longitude,
    );

    // 원본 지역 정보 저장
    _region = region;
    notifyListeners();
  }

  Future<bool> saveRoute() async {
    if (_routePoints.isEmpty) return false;

    // 한국어일 경우에만 변환
    final translatedRegion = CheckLanguageUtil.isKoreanRegion(_region)
        ? convertKoreanToJapanese(_region)
        : _region;

    await _runService.saveTrack(
      name: name,
      creatorId: creatorId,
      description: description,
      region: translatedRegion,
      distance: _distance,
      coordinates: _routePoints,
    );

    _routePoints.clear();
    _distance = 0.0;
    notifyListeners();
    return true;
  }

  Future<bool> saveRouteWithDetails(
      {required String name, required String description}) async {
    if (_routePoints.isEmpty) return false;

    this.name = name; // 사용자 입력 값 저장
    this.description = description;

    await saveRoute();
    return true;
  }

  void clearRoute() {
    _routePoints.clear();
    _distance = 0.0;
    _region = ""; // 지역 정보 초기화
    notifyListeners();
  }
}
