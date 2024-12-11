import 'package:geocoding/geocoding.dart';

class RegionHelper {
  /// 지역 정보 가져오기
  static Future<String> getRegionFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        return placemarks.first.administrativeArea ?? '';
      }
      return '';
    } catch (e) {
      print('Error retrieving region: $e');
      return '';
    }
  }
}
