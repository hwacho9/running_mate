import 'package:flutter/material.dart';
import 'package:running_mate/widgets/result_minimap.dart';

class PopularTrackCard extends StatelessWidget {
  final Map<String, dynamic> track;

  const PopularTrackCard({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  height: 100,
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
                track['name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 16),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
