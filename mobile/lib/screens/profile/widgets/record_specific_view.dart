import 'package:flutter/material.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class RecordSpecificView extends StatelessWidget {
  final String trackId;
  final String name;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;
  final double? participants;
  final int totalTime;
  final int pauseTime;

  const RecordSpecificView({
    super.key,
    required this.trackId,
    required this.name,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
    required this.totalTime,
    required this.pauseTime,
    this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final averagePace = distance > 0
        ? totalTime / (distance / 1000) // 초/km
        : 0.0;
    final averageSpeed = distance > 0
        ? ((distance / 1000) / (totalTime / 3600)) // m -> km 변환
        : 0.0;

    final formattedPace = formatTotalTime(averagePace.round());

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ResultMinimap(
              routePoints: routePoints,
              initialZoom: 14,
            ),
            const SizedBox(height: 16),
            const Divider(),

            // 거리 정보
            Text(
              formatDistance(distance),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "距離",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // 주요 데이터
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("時間", formatTotalTime(totalTime)),
                _buildStatItem("休憩時間", formatTotalTime(pauseTime)),
                _buildStatItem(
                    "평균 속도", "${averageSpeed.toStringAsFixed(1)} km/h"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("地域", region ?? "Unknown"),
                _buildStatItem("開始日", formatDate(createdAt)),
              ],
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 16),

            // 추가 정보
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
