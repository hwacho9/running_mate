import 'package:flutter/foundation.dart';
import 'package:running_mate/models/user_stats_model.dart';
import 'package:running_mate/services/user_stats_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UserStatsService _statsService;
  UserStats? _userStats;
  bool _isLoading = false;

  HomeViewModel(this._statsService);

  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  // UserStats 데이터 불러오기
  Future<void> loadUserStats(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userStats = await _statsService.getUserStats(userId);
    } catch (e) {
      print("Failed to load user stats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
