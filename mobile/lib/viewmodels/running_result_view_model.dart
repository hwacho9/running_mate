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
    String? trackId,
    required String region,
  }) async {
    try {
      _isSaving = true;
      notifyListeners();

      final totalTime = endTime.difference(startTime).inSeconds;
      print('Coordinates in saveUserRecord: $coordinates'); // 디버깅 로그

      await _userRecordService.saveUserRecord(
        userId: userId,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: distance,
        coordinates: coordinates,
        totalPauseTime: pauseTime, // 휴식 시간 전달
        region: region,
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

      // coordinates 복사본 생성
      final coordinatesCopy = List<Map<String, dynamic>>.from(coordinates);

      final totalTime = endTime.difference(startTime).inSeconds;
      print(
          'Coordinates in saveTrackWithUserRecord: $coordinatesCopy'); // 디버깅 로그

      final trackId = await _trackService.saveTrack(
        name: trackName,
        creatorId: userId,
        description: description,
        region: region,
        distance: distance,
        coordinates: coordinatesCopy
            .map((coord) => LatLng(coord['lat'], coord['lng']))
            .toList(),
      );
      print('Coordinates in 2: $coordinatesCopy'); // 디버깅 로그
      print('Track ID: $trackId'); // 트랙 ID 확인

      await _userRecordService.saveUserRecord(
        userId: userId,
        trackId: trackId,
        startTime: startTime,
        endTime: endTime,
        totalTime: totalTime,
        distance: distance,
        coordinates: coordinatesCopy,
        totalPauseTime: pauseTime, // 휴식 시간 전달
        region: region,
      );

      print('saveUserRecord completed successfully'); // 성공 여부 확인

      await _trackService.addToUserTracks(userId, trackId);
    } catch (e) {
      print('Failed to save track and user record: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
