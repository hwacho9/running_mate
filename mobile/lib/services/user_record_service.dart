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
    required List<Map<String, dynamic>> coordinates,
  }) async {
    await _firestore.collection('UserRecords').add({
      'user_id': userId,
      'track_id': trackId, // 트랙 ID가 없으면 null로 저장
      'start_time': startTime,
      'end_time': endTime,
      'total_time': totalTime,
      'distance': distance,
      'coordinates': coordinates,
    });
  }
}
