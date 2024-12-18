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
}
