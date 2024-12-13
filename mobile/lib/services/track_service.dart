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

    final trackId = docRef.id; // Retrieve the document ID

    // Add the track to UserTracks
    // await addToUserTracks(trackId);

    return trackId; // Return the document ID
  }

  Future<void> addToUserTracks(String trackId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final userTrackRef = _firestore.collection('UserTracks').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userTrackSnapshot = await transaction.get(userTrackRef);

      if (!userTrackSnapshot.exists) {
        // Create a new document if it doesn't exist
        transaction.set(userTrackRef, {
          'tracks': [
            {'track_id': trackId, 'joined_at': FieldValue.serverTimestamp()}
          ],
        });
      } else {
        // Update the existing document
        final tracks = List<Map<String, dynamic>>.from(
            userTrackSnapshot.data()?['tracks'] ?? []);

        // Prevent duplicate entries
        if (!tracks.any((track) => track['track_id'] == trackId)) {
          tracks.add(
              {'track_id': trackId, 'joined_at': FieldValue.serverTimestamp()});
          transaction.update(userTrackRef, {'tracks': tracks});
        }
      }
    });
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
