import 'package:flutter/material.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class TrackSpecificView extends StatelessWidget {
  final String trackId;
  final String name;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;

  const TrackSpecificView({
    super.key,
    required this.trackId,
    required this.name,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResultMinimap(
              routePoints: routePoints,
              initialZoom: 14,
            ),
            const SizedBox(height: 16),
            Text(
              "Distance: ${distance.toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Region: $region",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Created At: ${formatDate(createdAt)}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
