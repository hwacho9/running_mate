import 'package:flutter/material.dart';
import 'package:running_mate/services/track_service.dart';

class TrackSpecificViewModel extends ChangeNotifier {
  final Trackservice _trackService;

  TrackSpecificViewModel(this._trackService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> joinTrack(String userId, String trackId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _trackService.addToUserTracks(userId, trackId);
    } catch (e) {
      debugPrint("userId: $userId");
      debugPrint("trackId: $trackId");
      debugPrint('Failed to join track: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
