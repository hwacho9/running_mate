import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ResultMinimap extends StatelessWidget {
  final List<Map<String, dynamic>> routePoints;

  const ResultMinimap({super.key, required this.routePoints});

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
