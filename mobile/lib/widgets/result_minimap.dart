import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ResultMinimap extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;
  final double initialZoom;

  const ResultMinimap({
    super.key,
    required this.routePoints,
    required this.initialZoom,
  });

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLng(34.7, 135.2); // Default center
    }

    // Calculate the average latitude and longitude
    final double avgLat = (points.first.latitude + points.last.latitude) / 2;
    final double avgLng = (points.first.longitude + points.last.longitude) / 2;

    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    final points = routePoints
        .map((point) => LatLng(point['lat'] as double, point['lng'] as double))
        .toList();

    final initialCenter = _calculateCenter(points);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none, // 모든 상호작용 비활성화
          ),
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
