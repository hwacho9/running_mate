import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RunningResultView extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final List<Map<String, dynamic>> coordinates;
  final double totalDistance;

  const RunningResultView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.coordinates,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endTime.difference(startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Start Time: $startTime'),
            Text('End Time: $endTime'),
            Text('Duration: ${duration.inMinutes} minutes'),
            Text('Total Distance: ${totalDistance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 16),
            const Text(
              'Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MiniMap(routePoints: coordinates),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 뒤로가기
              },
              child: const Text('Back to Main'),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniMap extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;

  const MiniMap({super.key, required this.routePoints});

  @override
  Widget build(BuildContext context) {
    final points = routePoints
        .map((point) => LatLng(point['lat'] as double, point['lng'] as double))
        .toList();

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: points.isNotEmpty ? points.first : LatLng(34.7, 135.2),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
