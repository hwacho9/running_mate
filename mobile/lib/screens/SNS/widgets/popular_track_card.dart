import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:running_mate/screens/tracks/track_specific_view.dart';
import 'package:running_mate/utils/format.dart';
import 'package:running_mate/widgets/result_minimap.dart';

class PopularTrackCard extends StatelessWidget {
  final Map<String, dynamic> track;

  const PopularTrackCard({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TrackSpecificView로 이동하며 trackId와 필요한 정보를 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackSpecificView(
              trackId: track['track_id'] as String? ?? 'Unknown ID',
              name: track['name'] as String? ?? 'Unknown Name',
              description: track['description'] as String? ?? 'No Description',
              distance: (track['distance'] as num?)?.toDouble() ?? 0.0,
              region: track['region'] as String? ?? 'Unknown Region',
              createdAt: (track['created_at'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              routePoints: (track['coordinates'] as List<dynamic>?)
                      ?.map((point) => {
                            'lat': (point['lat'] as num?)?.toDouble() ?? 0.0,
                            'lng': (point['lng'] as num?)?.toDouble() ?? 0.0,
                          })
                      .toList() ??
                  [],
              participants:
                  (track['participants_count'] as num?)?.toDouble() ?? 0.0,
            ),
          ),
        );
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: ResultMinimap(
                        routePoints: (track['coordinates'] as List<dynamic>?)
                                ?.map((point) => {
                                      'lat': point['lat'] as double,
                                      'lng': point['lng'] as double,
                                    })
                                .toList() ??
                            [],
                        initialZoom: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (track['name'] ?? 'Unknown').length > 20
                        ? '${(track['name'] ?? 'Unknown').substring(0, 20)}...'
                        : track['name'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${track['participants_count'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.directions_run,
                        size: 16,
                        color: Colors.red,
                      ),
                      Text(
                        formatDistance(track['distance'].toDouble()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
