// services/run_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/models/route_model.dart';

class Trackservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> saveTrack({
    required String name,
    required String creatorId,
    required String description,
    required String region,
    required double distance,
    required List<LatLng> coordinates,
  }) async {
    // Convert coordinates to Firestore format
    final coordList = coordinates
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    // Save the track and get the document reference
    final docRef = await _firestore.collection('Tracks').add({
      'name': name,
      'creator_id': creatorId,
      'description': description,
      'region': region,
      'distance': distance,
      'created_at': FieldValue.serverTimestamp(),
      'coordinates': coordList,
    });

    final trackId = docRef.id; // Retrieve the document ID

    return trackId; // Return the document ID
  }

  // UserTracks 컬렉션에 사용자가 참여한 트랙을 추가하는 메서드
  Future<void> addToUserTracks(String userId, String trackId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final userDocRef = firestore.collection('UserTracks').doc(userId);

      // 명시적으로 현재 시간을 가져옵니다.
      final Timestamp currentTime = Timestamp.now();

      final userTrackData = {
        'track_id': trackId,
        'joined_at': currentTime,
      };

      // Check if the document already exists
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // If the document exists, update the tracks array
        print("Document exists. Updating...");
        await userDocRef.update({
          'tracks': FieldValue.arrayUnion([userTrackData]),
        });
      } else {
        print("Document does not exist. Creating new document...");
        // If the document does not exist, create it with the tracks array
        await userDocRef.set({
          'tracks': [userTrackData], // arrayUnion이 필요하지 않습니다.
        });
      }

      print('Track added successfully for user: $userId');
    } catch (e) {
      print('Failed to add track: $e');
      rethrow;
    }
  }

  Future<List<RouteModel>> fetchTracks() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final snapshot = await _firestore
        .collection('Tracks')
        .where('creator_id', isEqualTo: user.uid)
        .get();

    return snapshot.docs
        .map((doc) => RouteModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }
}
