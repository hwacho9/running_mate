import 'package:cloud_firestore/cloud_firestore.dart';

class SnsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 닉네임으로 유저 검색
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Error searching users: $e");
      rethrow;
    }
  }

  // 현재 지역에서 달리고 있는 사람 수
  Future<int> getCurrentRegionRunners(String region) async {
    final snapshot = await _firestore
        .collection('Users')
        .where('region', isEqualTo: region)
        .where('isRunning', isEqualTo: true)
        .get();
    return snapshot.size;
  }

  // 인기 트랙
  Future<List<Map<String, dynamic>>> getPopularTracks() async {
    final snapshot = await _firestore
        .collection('Tracks')
        .orderBy('participants_count', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // 친구들 중 러닝 중인 사람
  Future<List<Map<String, dynamic>>> getRunningFriends(String myUserId) async {
    final followingSnapshot = await _firestore
        .collection('Users')
        .doc(myUserId)
        .collection('Following')
        .get();

    final followedUserIds =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    final runners = <Map<String, dynamic>>[];

    for (int i = 0; i < followedUserIds.length; i += 10) {
      final chunk = followedUserIds.sublist(
        i,
        i + 10 > followedUserIds.length ? followedUserIds.length : i + 10,
      );

      final snapshot = await _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: chunk)
          .where('isRunning', isEqualTo: true)
          .get();

      runners.addAll(snapshot.docs.map((doc) => doc.data()));
    }
    return runners;
  }
}
