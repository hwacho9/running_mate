String formatDate(DateTime date) {
  return "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
}

String formatDistance(double distanceInMeters) {
  if (distanceInMeters >= 1000) {
    // 1000미터 이상이면 km로 변환
    return "${(distanceInMeters / 1000).toStringAsFixed(2)} km";
  } else {
    // 1000미터 미만이면 m로 표시
    return "${distanceInMeters.toStringAsFixed(0)} m";
  }
}
