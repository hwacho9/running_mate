import 'package:flutter/foundation.dart';
import 'package:running_mate/models/user_stats_model.dart';
import 'package:running_mate/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService;

  UserStats? _userStats;
  int _followingCount = 0;
  int _followersCount = 0;
  Map<DateTime, List<String>> _runDates = {}; // For calendar events

  bool _isLoading = false;

  UserStats? get userStats => _userStats;
  int get followingCount => _followingCount;
  int get followersCount => _followersCount;
  Map<DateTime, List<String>> get runDates => _runDates;
  bool get isLoading => _isLoading;

  ProfileViewModel(this._userService);

  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userStats = await _userService.fetchUserStats(userId);
      _followingCount = await _userService.fetchFollowingCount(userId);
      _followersCount = await _userService.fetchFollowersCount(userId);

      // Load monthly run data
      await loadRunDates(userId);
    } catch (e) {
      print("Error loading user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRunDates(String userId) async {
    try {
      final currentMonth = DateTime.now();
      final monthKey =
          "${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}";
      final dailyRecords =
          await _userService.fetchMonthlyRecords(userId, monthKey);

      print(_runDates);
      _runDates = {
        for (var record in dailyRecords)
          DateTime.parse(record): ["Ran on this day"]
      };
    } catch (e) {
      print("Error loading run dates: $e");
    }
  }
}
