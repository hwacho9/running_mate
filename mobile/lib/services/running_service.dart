import 'package:cloud_firestore/cloud_firestore.dart';

class RunningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 다른 사용자의 기록 불러오기
  Future<List<Map<String, dynamic>>> fetchUserRecords(String trackId) async {
    try {
      final querySnapshot = await _firestore
          .collection('UserRecords')
          .where('track_id', isEqualTo: trackId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // coordinates를 List<Map<String, dynamic>>로 변환
        final coordinates =
            List<Map<String, dynamic>>.from(data['coordinates'] as List);

        return {
          'user_id': data['user_id'],
          'coordinates': coordinates,
        };
      }).toList();
    } catch (e) {
      print('Failed to fetch user records: $e');
      return [];
    }
  }
}
