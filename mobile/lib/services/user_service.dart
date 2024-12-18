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

  Future<bool> isFollowingUser(
      String currentUserId, String profileUserId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(profileUserId)
          .get();

      return snapshot.exists;
    } catch (e) {
      print("Error checking following status: $e");
      return false;
    }
  }

  Future<void> followUser(String currentUserId, String profileUserId) async {
    try {
      final now = Timestamp.now();

      // Add to "Following" of current user
      await _firestore
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(profileUserId)
          .set({'followedAt': now});

      // Add to "Followers" of profile user
      await _firestore
          .collection('Users')
          .doc(profileUserId)
          .collection('Followers')
          .doc(currentUserId)
          .set({'followedAt': now});
    } catch (e) {
      print("Error following user: $e");
      rethrow;
    }
  }

  Future<void> unfollowUser(String currentUserId, String profileUserId) async {
    try {
      // Remove from "Following" of current user
      await _firestore
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(profileUserId)
          .delete();

      // Remove from "Followers" of profile user
      await _firestore
          .collection('Users')
          .doc(profileUserId)
          .collection('Followers')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print("Error unfollowing user: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();

      if (doc.exists) {
        return doc.data()!;
      } else {
        throw Exception("User document not found.");
      }
    } catch (e) {
      print("Error fetching user details: $e");
      rethrow;
    }
  }
}
