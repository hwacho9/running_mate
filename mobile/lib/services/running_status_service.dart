import 'package:cloud_firestore/cloud_firestore.dart';

class RunningStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateRunningStatus(String userId, bool isRunning) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'isRunning': isRunning,
      });
    } catch (e) {
      print("Failed to update running status: $e");
      rethrow;
    }
  }
}
