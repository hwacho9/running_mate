import 'dart:math';

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

  // 현재 지역에서 달리는 유저 수 Stream
  Stream<int> getCurrentRegionRunnersStream(String region) {
    return _firestore
        .collection('Users')
        .where('region', isEqualTo: region)
        .where('isRunning', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // 인기 트랙 (Still a one-time fetch as it doesn't need real-time updates)
  Future<List<Map<String, dynamic>>> getPopularTracks(String region) async {
    final snapshot = await _firestore
        .collection('Tracks')
        .where('is_public', isEqualTo: true) // Filter for is_public == true
        .where('region', isEqualTo: region)
        .orderBy('participants_count', descending: true)
        .limit(7) // Fetch the top 7 based on participants_count
        .get();

    final tracks = snapshot.docs.map((doc) => doc.data()).toList();

    // Shuffle the tracks randomly
    tracks.shuffle(Random());

    return tracks;
  }

  // 친구들 중 러닝 중인 사람 Stream
  Stream<List<Map<String, dynamic>>> getRunningFriendsStream(
      String myUserId) async* {
    final followingSnapshot = await _firestore
        .collection('Users')
        .doc(myUserId)
        .collection('Following')
        .get();

    final followedUserIds =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    for (int i = 0; i < followedUserIds.length; i += 10) {
      final chunk = followedUserIds.sublist(
        i,
        i + 10 > followedUserIds.length ? followedUserIds.length : i + 10,
      );

      yield* _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: chunk)
          .where('isRunning', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    }
  }
}
