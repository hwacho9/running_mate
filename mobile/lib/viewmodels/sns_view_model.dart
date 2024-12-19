import 'dart:async';

import 'package:flutter/material.dart';
import 'package:running_mate/services/sns_service.dart';

class SnsViewModel extends ChangeNotifier {
  final SnsService _snsService;

  int _currentRegionRunners = 0;
  List<Map<String, dynamic>> _popularTracks = [];
  List<Map<String, dynamic>> _runningFriends = [];
  bool _isLoading = true;

  StreamSubscription<int>? _regionRunnersSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _runningFriendsSubscription;

  int get currentRegionRunners => _currentRegionRunners;
  List<Map<String, dynamic>> get popularTracks => _popularTracks;
  List<Map<String, dynamic>> get runningFriends => _runningFriends;
  bool get isLoading => _isLoading;

  SnsViewModel(this._snsService);

  Future<void> loadSNSData(String region, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load popular tracks (one-time)
      _popularTracks = await _snsService.getPopularTracks(region);

      // Start listening to streams
      _regionRunnersSubscription =
          _snsService.getCurrentRegionRunnersStream(region).listen((count) {
        _currentRegionRunners = count;
        notifyListeners();
      });

      _runningFriendsSubscription =
          _snsService.getRunningFriendsStream(userId).listen((friends) {
        _runningFriends = friends;
        notifyListeners();
      });
    } catch (e) {
      print("Error loading SNS data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _regionRunnersSubscription?.cancel();
    _runningFriendsSubscription?.cancel();
    super.dispose();
  }
}
