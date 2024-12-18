import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:running_mate/models/user_stats_model.dart';

class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 통계 데이터 가져오기
  Stream<UserStats> getUserStats(String userId) {
    try {
      final docRef = _firestore.collection('UserStats').doc(userId);
      return docRef.snapshots().map((docSnapshot) {
        if (!docSnapshot.exists) {
          throw Exception("User stats not found");
        }

        final data = docSnapshot.data() as Map<String, dynamic>;
        return UserStats.fromFirestore(data);
      });
    } catch (e) {
      print("Error fetching user stats: $e");
      rethrow;
    }
  }

  // 사용자 통계 업데이트 (예: 총 거리, 런 횟수 등 업데이트)
  Future<void> updateUserStats(
      String userId, Map<String, dynamic> updates) async {
    try {
      final docRef = _firestore.collection('UserStats').doc(userId);
      await docRef.update(updates);
    } catch (e) {
      print("Error updating user stats: $e");
      rethrow;
    }
  }

  // 새로운 기록 추가하기 (특정 날짜에 추가)
  Future<void> addDailyRecord(String userId, String month, String day,
      Map<String, dynamic> record) async {
    try {
      final docRef = _firestore
          .collection('UserStats')
          .doc(userId)
          .collection(month)
          .doc(day);

      // 기존 records 배열에 추가
      await docRef.set({
        'date': day,
        'records': FieldValue.arrayUnion([record]),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding daily record: $e");
      rethrow;
    }
  }
}
