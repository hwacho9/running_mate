import 'package:flutter/foundation.dart';
import 'package:running_mate/services/track_service.dart';

class TrackEditViewModel extends ChangeNotifier {
  final Trackservice _trackService;
  bool _isPublic = false;

  TrackEditViewModel(this._trackService);

  bool get isPublic => _isPublic;

  Future<void> updatePublicStatus(String trackId, bool isPublic) async {
    try {
      await _trackService.updateTrackPublicStatus(trackId, isPublic);
      _isPublic = isPublic;
      notifyListeners();
    } catch (e) {
      print("Failed to update public status: $e");
    }
  }

  void fetchInitialPublicStatus(bool initialStatus) {
    _isPublic = initialStatus;
    notifyListeners();
  }

  Future<bool> deleteTrack(String trackId) async {
    try {
      await _trackService.deleteTrack(trackId);
      return true;
    } catch (e) {
      print("Failed to delete track: $e");
      return false;
    }
  }
}
