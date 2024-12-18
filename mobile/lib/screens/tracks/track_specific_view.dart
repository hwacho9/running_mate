import 'package:flutter/material.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/tracks/track_edit_view.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackEditView(trackId: trackId),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                  "Distance: ${formatDistance(distance)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: CircleFloatingActionButton(
                backgroundColor: Colors.orange,
                size: 72.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RunningView(),
                    ),
                  );
                },
                icon: Icons.play_arrow,
                tooltip: 'Start',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
