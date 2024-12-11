import 'dart:math';

class DirectionUtil {
  /// 방향 값을 라디안으로 변환
  static double headingToRadians(double heading) {
    return heading * (pi / 180); // pi는 dart:math에서 가져옴
  }

  /// 두 위치 사이의 방향 계산 (optional 기능 확장 가능)
  /// - 사용하지 않는 경우 삭제해도 무방
  static double calculateBearing(
      double startLat, double startLng, double endLat, double endLng) {
    final startLatRad = startLat * (pi / 180);
    final startLngRad = startLng * (pi / 180);
    final endLatRad = endLat * (pi / 180);
    final endLngRad = endLng * (pi / 180);

    final dLng = endLngRad - startLngRad;

    final y = sin(dLng) * cos(endLatRad);
    final x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(dLng);

    final bearing = atan2(y, x);

    // 라디안 값을 도(degree)로 변환
    return (bearing * (180 / pi) + 360) % 360;
  }
}
