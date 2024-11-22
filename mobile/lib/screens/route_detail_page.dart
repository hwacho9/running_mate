import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteDetailPage extends StatelessWidget {
  final String routeName;
  final int participants;
  final List<LatLng> routePoints;

  const RouteDetailPage({
    super.key,
    required this.routeName,
    required this.participants,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(34.70, 135.2), // 지도 중심 좌표
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
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Participants'),
            subtitle: Text('$participants runners'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement race functionality here
            },
            child: const Text('Start Running'),
          ),
        ],
      ),
    );
  }
}
