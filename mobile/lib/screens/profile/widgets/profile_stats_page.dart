import 'package:flutter/material.dart';
import 'package:running_mate/screens/profile/widgets/profile_stat_grid.dart';
import 'package:running_mate/screens/profile/widgets/profile_run_calendar.dart';

class ProfileStatsPage extends StatelessWidget {
  final bool isLoading;
  final dynamic userStats;
  final Map<DateTime, List<String>> runDates;

  const ProfileStatsPage({
    super.key,
    required this.isLoading,
    required this.userStats,
    required this.runDates,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                userStats != null
                    ? ProfileStatGrid(
                        totalRunCount: userStats.totalRunCount,
                        totalRunDays: userStats.totalRunDays,
                        currentStreak: userStats.currentStreak,
                        totalDistance: userStats.totalDistance,
                        longestStreak: userStats.longestStreak,
                        totalTime: userStats.totalTime,
                        lastRunDate: userStats.lastRunDate!.toDate(),
                      )
                    : ProfileStatGrid(
                        totalRunCount: 0,
                        totalRunDays: 0,
                        longestStreak: 0,
                        currentStreak: 0,
                        totalDistance: 0,
                        totalTime: 0,
                        lastRunDate: DateTime.now(),
                      ),
                const SizedBox(height: 16),
                ProfileRunCalendar(runDates: runDates),
              ],
            ),
          );
  }
}
