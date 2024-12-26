import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  String _region = "";

  LatLng? get currentPosition => _currentPosition;
  String get region => _region;

  LocationProvider() {
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    await _requestLocationPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();

    // 지역 정보 업데이트
    _region = await _getRegionFromLocation() ?? "Unknown";
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이동 시 업데이트
      ),
    ).listen((Position pos) async {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _region = await _getRegionFromLocation() ?? "Unknown";
      notifyListeners();
    });
  }

  Future<void> _requestLocationPermission() async {
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

  Future<String?> _getRegionFromLocation() async {
    try {
      final _region = await RegionHelper.getRegionFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      final translatedRegion = CheckLanguageUtil.isKoreanRegion(_region)
          ? convertKoreanToJapanese(_region)
          : _region;

      return translatedRegion;
    } catch (e) {
      print("위치 정보 오류: $e");
      return null;
    }
  }
}
