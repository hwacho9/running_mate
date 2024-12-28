import 'package:flutter/foundation.dart';
import 'package:running_mate/services/track_service.dart';

class TrackEditViewModel extends ChangeNotifier {
  final Trackservice _trackService;

  String? _currentTrackId; // 현재 트랙 ID
  bool _isPublic = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  TrackEditViewModel(this._trackService);

  bool get isPublic => _isPublic;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialPublicStatus(String trackId) async {
    if (_isInitialized && _currentTrackId == trackId) {
      // 이미 초기화된 상태면 호출하지 않음
      return;
    }

    _currentTrackId = trackId;
    _isInitialized = false; // 새 트랙 로딩
    _isLoading = true;
    notifyListeners();

    try {
      final initialStatus = await _trackService.getTrackPublicStatus(trackId);
      _isPublic = initialStatus;
      _isInitialized = true; // 초기화 완료
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

  Future<bool> deleteTrack(String trackId, userId) async {
    try {
      await _trackService.deleteTrack(trackId, userId);
      return true;
    } catch (e) {
      print("Failed to delete track: $e");
      return false;
    }
  }
}
