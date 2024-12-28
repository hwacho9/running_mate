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

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
}

String formatPauseTime(Duration pauseTime) {
  if (pauseTime.inMinutes > 0) {
    final minutes = pauseTime.inMinutes;
    return "${minutes}分"; // XX分 형식으로 표시
  } else {
    final seconds = pauseTime.inSeconds;
    return "${seconds}秒"; // XX秒 형식으로 표시
  }
}

String formatTime(DateTime time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}

String formatTotalTime(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  if (hours > 0) {
    return "$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  } else {
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
