import 'package:flutter/material.dart';
import 'package:running_mate/models/route_model.dart';
import 'package:running_mate/services/track_service.dart';

class MyTracksViewModel extends ChangeNotifier {
  final Trackservice _trackService;

  MyTracksViewModel(this._trackService);

  List<RouteModel> _myTracks = [];
  List<RouteModel> _participatedTracks = [];
  bool _isLoading = false;

  List<RouteModel> get myTracks => _myTracks;
  List<RouteModel> get participatedTracks => _participatedTracks;
  bool get isLoading => _isLoading;

  /// 사용자 트랙 불러오기
  Future<void> loadUserTracks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tracks = await _trackService.fetchTracks(userId);
      _myTracks = tracks['myTracks'] ?? [];
      _participatedTracks = tracks['participatedTracks'] ?? [];
    } catch (e) {
      print("Error loading tracks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
