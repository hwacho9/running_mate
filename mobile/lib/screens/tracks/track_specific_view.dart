import 'package:flutter/material.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/tracks/track_edit_view.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class TrackSpecificView extends StatelessWidget {
  final String trackId;
  final String name;
  final String description;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;
  final double? participants;

  const TrackSpecificView(
      {super.key,
      required this.trackId,
      required this.name,
      required this.description,
      required this.distance,
      required this.region,
      required this.createdAt,
      required this.routePoints,
      this.participants});

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
                // 참가자 표시
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orangeAccent,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // 아이콘과 숫자 간격
                    Text(
                      "${participants?.toStringAsFixed(0) ?? 0}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  "Distance: ${formatDistance(distance)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Text(
                  "description: $description",
                  style: const TextStyle(fontSize: 16),
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
                      builder: (context) => RunningView(
                        routePoints: routePoints,
                        trackId: trackId,
                      ),
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
