import 'package:flutter/foundation.dart';
import 'package:running_mate/services/user_record_service.dart';
import 'package:running_mate/services/track_service.dart';
import 'package:latlong2/latlong.dart';

class RunningResultViewModel extends ChangeNotifier {
  final UserRecordService _userRecordService;
  final Trackservice _trackService;

  RunningResultViewModel(this._userRecordService, this._trackService);

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> saveUserRecord({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required double distance,
    required List<Map<String, dynamic>> coordinates,
    required Duration pauseTime, // 추가된 pauseTime 파라미터
  }) async {
    try {
      _isSaving = true;
      notifyListeners();

      final totalTime = endTime.difference(startTime).inSeconds;

      await _userRecordService.saveUserRecord(
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: distance,
        coordinates: coordinates,
        totalPauseTime: pauseTime, // 휴식 시간 전달
      );
    } catch (e) {
      print('Failed to save user record: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveTrackWithUserRecord({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required double distance,
    required List<Map<String, dynamic>> coordinates,
    required String trackName,
    required String description,
    required String region,
    required Duration pauseTime, // 추가된 pauseTime 파라미터
  }) async {
    try {
      _isSaving = true;
      notifyListeners();

      final totalTime = endTime.difference(startTime).inSeconds;

      final trackId = await _trackService.saveTrack(
        name: trackName,
        creatorId: userId,
        description: description,
        region: region,
        distance: distance,
        coordinates: coordinates
            .map((coord) => LatLng(coord['lat'], coord['lng']))
            .toList(),
      );

      await _userRecordService.saveUserRecord(
        userId: userId,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: distance,
        coordinates: coordinates,
        totalPauseTime: pauseTime, // 휴식 시간 전달
      );
    } catch (e) {
      print('Failed to save track and user record: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
