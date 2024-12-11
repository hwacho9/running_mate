import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/services/track_service.dart';
import 'package:running_mate/services/user_record_service.dart';

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

  Future<void> _saveUserRecord(BuildContext context) async {
    try {
      final totalTime = endTime.difference(startTime).inSeconds;

      await UserRecordService().saveUserRecord(
        userId: 'USER_ID', // 실제 사용자 ID
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: totalDistance,
        coordinates: coordinates,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User record saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save user record.')),
      );
    }
  }

  Future<void> _saveTrackWithUserRecord(BuildContext context) async {
    try {
      final totalTime = endTime.difference(startTime).inSeconds;

      final trackId = await Trackservice().saveTrack(
        name: 'My Track',
        creatorId: 'USER_ID', // 실제 사용자 ID
        description: 'A beautiful running track',
        region: 'Seoul', // 지역 정보
        distance: totalDistance,
        coordinates: coordinates
            .map((coord) => LatLng(coord['lat'], coord['lng']))
            .toList(),
      );

      await UserRecordService().saveUserRecord(
        userId: 'USER_ID', // 실제 사용자 ID
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: totalDistance,
        coordinates: coordinates,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Track and user record saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save track and user record.')),
      );
    }
  }

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
              onPressed: () => _saveUserRecord(context),
              child: const Text('Save User Record'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _saveTrackWithUserRecord(context),
              child: const Text('Save Track and User Record'),
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
