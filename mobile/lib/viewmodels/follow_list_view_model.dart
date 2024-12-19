import 'package:flutter/foundation.dart';
import 'package:running_mate/services/user_service.dart';

class FollowListViewModel extends ChangeNotifier {
  final UserService _userService;

  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _followers = [];

  List<Map<String, dynamic>> get following => _following;
  List<Map<String, dynamic>> get followers => _followers;

  FollowListViewModel(this._userService);

  Future<void> loadFollowing(String userId) async {
    try {
      _following = await _userService.fetchFollowing(userId);
    } catch (e) {
      print("Error loading following list: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadFollowers(String userId) async {
    try {
      _followers = await _userService.fetchFollowers(userId);
    } catch (e) {
      print("Error loading followers list: $e");
    } finally {
      notifyListeners();
    }
  }
}
