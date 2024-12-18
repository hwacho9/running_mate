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
}
