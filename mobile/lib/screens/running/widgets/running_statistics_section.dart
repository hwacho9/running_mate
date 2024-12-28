import 'package:flutter/material.dart';
import 'package:running_mate/utils/format.dart';

class RunningStatisticsSection extends StatelessWidget {
  final double totalDistance;
  final Duration duration;
  final double averageSpeed;
  final Duration pauseTime;
  final DateTime startTime;
  final DateTime endTime;

  const RunningStatisticsSection({
    super.key,
    required this.totalDistance,
    required this.duration,
    required this.averageSpeed,
    required this.pauseTime,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatistic("距離", "${formatDistance(totalDistance)}"),
            _buildStatistic("時間", formatDuration(duration)),
            _buildStatistic("平均速度", "${averageSpeed.toStringAsFixed(1)} km/h"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatistic("休憩時間", formatPauseTime(pauseTime)),
            _buildStatistic("開始時間", formatTime(startTime)),
            _buildStatistic("終了時間", formatTime(endTime)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistic(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
