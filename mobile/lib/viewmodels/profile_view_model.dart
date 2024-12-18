import 'package:flutter/foundation.dart';
import 'package:running_mate/models/user_stats_model.dart';
import 'package:running_mate/services/user_record_service.dart';
import 'package:running_mate/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService;
  final UserRecordService _userRecordService;

  List<Map<String, dynamic>> _userRecords = [];
  bool _isLoadingRecords = false;

  List<Map<String, dynamic>> get userRecords => _userRecords;
  bool get isLoadingRecords => _isLoadingRecords;

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

  ProfileViewModel(this._userService, this._userRecordService);

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

      print("rundate ${_runDates}");
      _runDates = {
        for (var record in dailyRecords)
          DateTime.parse(record): ["Ran on this day"]
      };
    } catch (e) {
      print("Error loading run dates: $e");
    }
  }

  Future<void> loadUserRecords(String userId) async {
    _isLoadingRecords = true;
    notifyListeners();

    try {
      _userRecords = await _userRecordService.fetchUserRecords(userId);
      print("로드된 유저 기록: $_userRecords");
    } catch (e) {
      print("유저 기록 로드 중 오류 발생: $e");
    } finally {
      _isLoadingRecords = false;
      notifyListeners();
    }
  }
}
