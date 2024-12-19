import 'package:flutter/material.dart';
import 'package:running_mate/services/sns_service.dart';

class SnsViewModel extends ChangeNotifier {
  final SnsService _snsService;

  int _currentRegionRunners = 0;
  List<Map<String, dynamic>> _popularTracks = [];
  List<Map<String, dynamic>> _runningFriends = [];
  bool _isLoading = true;

  int get currentRegionRunners => _currentRegionRunners;
  List<Map<String, dynamic>> get popularTracks => _popularTracks;
  List<Map<String, dynamic>> get runningFriends => _runningFriends;
  bool get isLoading => _isLoading;

  SnsViewModel(this._snsService);

  Future<void> loadSNSData(String region, String userId) async {
    _isLoading = true;
    notifyListeners();

    print("region : ${region}");

    try {
      _currentRegionRunners = await _snsService.getCurrentRegionRunners(region);
      _popularTracks = await _snsService.getPopularTracks();
      _runningFriends = await _snsService.getRunningFriends(userId);
    } catch (e) {
      print("Error loading SNS data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
