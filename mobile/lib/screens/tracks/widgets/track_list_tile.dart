import 'package:flutter/material.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';
import 'package:running_mate/screens/tracks/track_specific_view.dart';

class TrackListTile extends StatelessWidget {
  final String trackId; // 트랙 고유 ID 추가
  final String name;
  final String description;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;
  final double participants;

  const TrackListTile({
    super.key,
    required this.trackId, // 트랙 ID 추가
    required this.name,
    required this.description,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
    this.participants = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TrackSpecificView로 이동하며 trackId와 필요한 정보를 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackSpecificView(
              trackId: trackId,
              name: name,
              description: description,
              distance: distance,
              region: region,
              createdAt: createdAt,
              routePoints: routePoints,
              participants: participants,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 140,
        child: Container(
          color: Colors.white,
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
                        "${formatDistance(distance)}· $region",
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
