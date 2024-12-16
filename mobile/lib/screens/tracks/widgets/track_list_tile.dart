import 'package:flutter/material.dart';
import 'package:running_mate/screens/running/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class TrackListTile extends StatelessWidget {
  final String name;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;

  const TrackListTile({
    super.key,
    required this.name,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Card의 전체 높이 조정
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 100, // 지도 섹션의 너비
                height: 100, // 지도 섹션의 높이
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ResultMinimap(
                    routePoints: routePoints,
                    initialZoom: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12), // 지도와 정보 사이의 간격
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
                      "$distance km · $region",
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
    );
  }
}
