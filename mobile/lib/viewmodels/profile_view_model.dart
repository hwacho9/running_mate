import 'package:flutter/foundation.dart';
import 'package:running_mate/models/user_stats_model.dart';
import 'package:running_mate/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userservice;
  UserStats? _userStats;
  int _followingCount = 0;
  int _followersCount = 0;

  UserStats? get userStats => _userStats;
  int get followingCount => _followingCount;
  int get followersCount => _followersCount;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProfileViewModel(this._userservice);

  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userStats = await _userservice.fetchUserStats(userId);
      _followingCount = await _userservice.fetchFollowingCount(userId);
      _followersCount = await _userservice.fetchFollowersCount(userId);
    } catch (e) {
      print("Error loading user profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
