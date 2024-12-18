import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:running_mate/models/user_stats_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserStats?> fetchUserStats(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('UserStats').doc(userId).get();

      if (docSnapshot.exists) {
        return UserStats.fromFirestore(docSnapshot.data()!);
      }
    } catch (e) {
      print("Error fetching user stats: $e");
    }
    return null;
  }

  Future<int> fetchFollowingCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Following')
          .get();
      return snapshot.size;
    } catch (e) {
      print("Error fetching following count: $e");
      return 0;
    }
  }

  Future<int> fetchFollowersCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Followers')
          .get();
      return snapshot.size;
    } catch (e) {
      print("Error fetching followers count: $e");
      return 0;
    }
  }

  // 특정 월별 컬렉션 데이터 가져오기 (yyyy-MM)
  Future<List<String>> fetchMonthlyRecords(String userId, String month) async {
    try {
      final collectionRef =
          _firestore.collection('UserStats').doc(userId).collection(month);
      final snapshot = await collectionRef.get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching monthly records: $e");
      return [];
    }
  }

  // 특정 날짜 기록 가져오기 (yyyy-MM-dd)
  Future<List<Map<String, dynamic>>> getDailyRecords(
      String userId, String month, String day) async {
    try {
      final docRef = _firestore
          .collection('UserStats')
          .doc(userId)
          .collection(month)
          .doc(day);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) return [];

      final data = docSnapshot.data() as Map<String, dynamic>;
      final records = data['records'] as List<dynamic>?;

      return records?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    } catch (e) {
      print("Error fetching daily records: $e");
      rethrow;
    }
  }
}
