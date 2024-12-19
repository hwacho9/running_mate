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
      'participants_count': 1, // 기본값 1로 설정
      'is_public': false, // 기본값 false로 설정
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

      // Track 도큐먼트에서 creator_id 조회
      final trackDoc = await firestore.collection('Tracks').doc(trackId).get();
      if (!trackDoc.exists) {
        throw Exception("Track does not exist.");
      }

      final trackData = trackDoc.data()!;
      final creatorId = trackData['creator_id'] as String;

      // 내 루트인지 다른 사람의 루트인지 확인
      final isMyTrack = creatorId == userId;

      // 추가할 데이터 구성
      final userTrackData = {
        'track_id': trackId,
        'joined_at': currentTime,
        'is_my_track': isMyTrack, // 내 루트 여부 추가
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

  Future<void> updateTrackPublicStatus(String trackId, bool isPublic) async {
    try {
      await _firestore.collection('Tracks').doc(trackId).update({
        'is_public': isPublic,
      });
    } catch (e) {
      print("Failed to update track public status: $e");
      rethrow;
    }
  }

  Future<void> deleteTrack(String trackId) async {
    try {
      await _firestore.collection('Tracks').doc(trackId).delete();
    } catch (e) {
      print("Failed to delete track: $e");
      rethrow;
    }
  }

  /// 사용자의 트랙 목록 가져오기
  Future<List<RouteModel>> fetchTracks(String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // UserTracks에서 사용자의 트랙 ID 가져오기
    final userTracksDoc =
        await _firestore.collection('UserTracks').doc(userId).get();

    if (!userTracksDoc.exists) {
      return [];
    }

    final tracks = userTracksDoc['tracks'] as List<dynamic>;
    List<String> trackIds = tracks.map((e) => e['track_id'] as String).toList();

    print("User tracks: $trackIds");

    // Tracks 컬렉션에서 트랙 세부 정보 가져오기
    List<RouteModel> userRoutes = [];
    for (String trackId in trackIds) {
      final trackDoc = await _firestore.collection('Tracks').doc(trackId).get();
      if (trackDoc.exists) {
        userRoutes.add(RouteModel.fromFirestore(trackId, trackDoc.data()!));
      }
    }

    return userRoutes;
  }
}
