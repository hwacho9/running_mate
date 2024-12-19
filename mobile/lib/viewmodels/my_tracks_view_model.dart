import 'package:flutter/foundation.dart';
import 'package:running_mate/models/route_model.dart';
import 'package:running_mate/services/track_service.dart';

class MyTracksViewModel extends ChangeNotifier {
  final Trackservice _trackService;

  MyTracksViewModel(this._trackService);

  List<RouteModel> _tracks = [];
  bool _isLoading = false;

  List<RouteModel> get tracks => _tracks;
  bool get isLoading => _isLoading;

  /// 사용자 트랙 불러오기
  Future<void> loadUserTracks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tracks = await _trackService.fetchTracks(userId);
      print(_tracks);
    } catch (e) {
      print("Error loading tracks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
