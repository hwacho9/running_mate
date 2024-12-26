import 'package:flutter/foundation.dart';
import 'package:running_mate/services/track_service.dart';

class TrackEditViewModel extends ChangeNotifier {
  final Trackservice _trackService;
  bool _isPublic = false;
  bool _isInitialized = false; // 초기화 여부
  bool _isLoading = false; // 로딩 상태

  TrackEditViewModel(this._trackService);

  bool get isPublic => _isPublic;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialPublicStatus(String trackId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final initialStatus = await _trackService.getTrackPublicStatus(trackId);
      _isPublic = initialStatus;
      _isInitialized = true;
    } catch (e) {
      print("Failed to fetch initial public status: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePublicStatus(String trackId, bool isPublic) async {
    try {
      await _trackService.updateTrackPublicStatus(trackId, isPublic);
      _isPublic = isPublic;
      notifyListeners();
    } catch (e) {
      print("Failed to update public status: $e");
    }
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
