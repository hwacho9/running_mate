import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final int totalRunCount;
  final int totalRunDays;
  final int longestStreak;
  final int currentStreak;
  final double totalDistance;
  final int totalTime; // in seconds
  final Timestamp? lastRunDate;

  // 생성자
  UserStats({
    required this.totalRunCount,
    required this.totalRunDays,
    required this.longestStreak,
    required this.currentStreak,
    required this.totalDistance,
    required this.totalTime,
    this.lastRunDate,
  });

  // Firestore 데이터로부터 모델 생성
  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    return UserStats(
      totalRunCount: data['total_run_count'] ?? 0,
      totalRunDays: data['total_run_days'] ?? 0,
      longestStreak: data['longest_streak'] ?? 0,
      currentStreak: data['current_streak'] ?? 0,
      totalDistance: (data['total_distance'] ?? 0).toDouble(),
      totalTime: data['total_time'] ?? 0,
      lastRunDate: data['last_run_date'] as Timestamp?,
    );
  }
}
