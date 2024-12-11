// services/run_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RunService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTrack({
    required String name,
    required String creatorId,
    required String description,
    required String region,
    required double distance,
    required List<LatLng> coordinates,
  }) async {
    // coordinates를 Firestore에 맞게 변환
    final coordList = coordinates
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await _firestore.collection('Tracks').add({
      'name': name,
      'creator_id': creatorId,
      'description': description,
      'region': region,
      'distance': distance,
      'created_at': FieldValue.serverTimestamp(),
      'coordinates': coordList,
    });
  }
}
