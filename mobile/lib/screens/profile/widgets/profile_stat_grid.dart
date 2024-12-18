import 'package:flutter/material.dart';
import 'package:running_mate/utils/format.dart';
import 'package:running_mate/widgets/stats_card.dart';

class ProfileStatGrid extends StatelessWidget {
  final int totalRunCount;
  final int totalRunDays;
  final int longestStreak;
  final int currentStreak;
  final double totalDistance;
  final int totalTime; // in seconds
  final DateTime lastRunDate;

  const ProfileStatGrid({
    super.key,
    required this.totalRunCount,
    required this.totalRunDays,
    required this.longestStreak,
    required this.currentStreak,
    required this.totalDistance,
    required this.totalTime,
    required this.lastRunDate,
  });

  String _formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours}h ${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {"icon": Icons.route, "title": "走ったトラック数", "value": "$totalRunCount 回"},
      {
        "icon": Icons.calendar_today,
        "title": "総ラン日",
        "value": "$totalRunDays 日"
      },
      {
        "icon": Icons.local_fire_department,
        "title": "最長連続ラン日",
        "value": "$longestStreak 日"
      },
      {
        "icon": Icons.local_fire_department,
        "title": "連続ラン日",
        "value": "$currentStreak 日"
      },
      {
        "icon": Icons.directions_run,
        "title": "総距離",
        "value": formatDistance(totalDistance),
      },
      {
        "icon": Icons.timer,
        "title": "総時間",
        "value": _formatTotalTime(totalTime),
      },
      {
        "icon": Icons.event,
        "title": "最終ラン日",
        "value": formatDate(lastRunDate),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.7,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatCard(
          icon: stat["icon"] as IconData,
          title: stat["title"] as String,
          value: stat["value"] as String,
        );
      },
    );
  }
}
