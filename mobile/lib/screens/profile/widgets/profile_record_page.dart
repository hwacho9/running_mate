import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:running_mate/screens/profile/widgets/record_list_tile.dart';

class ProfileRecordsPage extends StatelessWidget {
  final bool isLoadingRecords;
  final List<Map<String, dynamic>> userRecords;

  const ProfileRecordsPage({
    super.key,
    required this.isLoadingRecords,
    required this.userRecords,
  });

  @override
  Widget build(BuildContext context) {
    return isLoadingRecords
        ? const Center(child: CircularProgressIndicator())
        : userRecords.isEmpty
            ? const Center(
                child: Text(
                  '記録なし',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: userRecords.length,
                itemBuilder: (context, index) {
                  final record = userRecords[index];
                  final startTime =
                      record['start_time']?.toDate() ?? DateTime.now();
                  final formattedStartTime =
                      DateFormat('yyyy-MM-dd HH:mm').format(startTime);

                  return RecordListTile(
                    trackId: record['track_id'] ?? 'Unknown',
                    name: formattedStartTime,
                    distance: record['distance'] ?? 0.0,
                    region: record['region'] ?? 'Unknown',
                    createdAt: startTime,
                    totalTime: record['total_time'],
                    routePoints: (record['coordinates'] as List<dynamic>)
                        .map((coord) => Map<String, dynamic>.from(coord))
                        .toList(),
                    pauseTime: record['pause_time'] ?? 0,
                  );
                },
              );
  }
}
