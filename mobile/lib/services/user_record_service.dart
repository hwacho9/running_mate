import 'package:cloud_firestore/cloud_firestore.dart';

class UserRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserRecord({
    required String userId,
    String? trackId,
    required DateTime startTime,
    required DateTime endTime,
    required int totalTime,
    required double distance,
    required Duration totalPauseTime, // 일시정지 시간 추가
    required List<Map<String, dynamic>> coordinates,
  }) async {
    await _firestore.collection('UserRecords').add({
      'user_id': userId,
      'track_id': trackId,
      'start_time': startTime,
      'end_time': endTime,
      'total_time': totalTime,
      'pause_time': totalPauseTime.inSeconds, // 초 단위로 저장
      'distance': distance,
      'coordinates': coordinates,
    });
  }
}
