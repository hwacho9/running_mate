import 'package:flutter/material.dart';
import 'package:running_mate/utils/format.dart';
import 'package:running_mate/widgets/stats_card.dart';

class StatGrid extends StatelessWidget {
  final int totalRunCount;
  final int totalRunDays;
  final int currentStreak;
  final double totalDistance;

  const StatGrid({
    super.key,
    required this.totalRunCount,
    required this.totalRunDays,
    required this.currentStreak,
    required this.totalDistance,
  });

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
        "title": "連続ラン日",
        "value": "$currentStreak 日"
      },
      {
        "icon": Icons.directions_run,
        "title": "総距離",
        "value": formatDistance(totalDistance)
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
