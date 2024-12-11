// services/run_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    return docRef.id; // Return the document ID
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
