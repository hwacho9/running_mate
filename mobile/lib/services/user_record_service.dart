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
    required String region,
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
      'region': region,
    });
  }

  Future<List<Map<String, dynamic>>> fetchUserRecords(String userId) async {
    try {
      // Firestore에서 UserRecords 컬렉션의 user_id 필터링
      final snapshot = await _firestore
          .collection('UserRecords')
          .where('user_id', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No records found for user $userId");
        return [];
      }

      // 기록 데이터 매핑
      List<Map<String, dynamic>> userRecords = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("Record data: $data");

        userRecords.add({
          'track_id': data['track_id'] ?? 'Unknown',
          'start_time': data['start_time'],
          'end_time': data['end_time'],
          'total_time': data['total_time'] ?? 0,
          'distance': data['distance'] ?? 0.0,
          'coordinates': (data['coordinates'] as List<dynamic>? ?? [])
              .map((coord) => Map<String, dynamic>.from(coord))
              .toList(), // 올바른 타입으로 변환
          'region': data['region'] ?? 'Unknown',
        });
      }

      return userRecords;
    } catch (e) {
      print("Error fetching user records: $e");
      return [];
    }
  }
}
