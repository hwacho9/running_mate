import 'package:flutter/material.dart';
import 'package:running_mate/screens/profile/widgets/record_specific_view.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class RecordListTile extends StatelessWidget {
  final String trackId;
  final String name;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;
  final double participants;
  final int totalTime;
  final int pauseTime;

  const RecordListTile({
    super.key,
    required this.trackId,
    required this.name,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
    this.totalTime = 0, // 기본값 설정
    this.pauseTime = 0, // 기본값 설정
    this.participants = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordSpecificView(
              trackId: trackId,
              name: name,
              distance: distance,
              region: region,
              createdAt: createdAt,
              routePoints: routePoints,
              participants: participants,
              totalTime: totalTime, // null-safe 처리
              pauseTime: pauseTime, // null-safe 처리
            ),
          ),
        );
      },
      child: SizedBox(
        height: 140,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ResultMinimap(
                      routePoints: routePoints,
                      initialZoom: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${formatDistance(distance)} · $region · ${formatTotalTime(totalTime)}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
