// services/run_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/models/route_model.dart';

class Trackservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TODO 2: set방식으로 바꾸기
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

    // Update the document to include the trackId
    await docRef.update({'track_id': trackId});

    return trackId; // Return the document ID
  }

  // UserTracks 컬렉션에 사용자가 참여한 트랙을 추가하는 메서드
  Future<void> addToUserTracks(String userId, String trackId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    print(trackId);
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

  Future<void> deleteTrack(String trackId, String userId) async {
    try {
      final batch = _firestore.batch();

      // 1. Delete the track document in the Tracks collection
      final trackRef = _firestore.collection('Tracks').doc(trackId);
      batch.delete(trackRef);

      // 2. Find the UserTracks document for the specific user
      final userTrackRef = _firestore.collection('UserTracks').doc(userId);
      final userTrackSnapshot = await userTrackRef.get();

      if (userTrackSnapshot.exists) {
        final userTrackData = userTrackSnapshot.data();
        final tracks =
            List<Map<String, dynamic>>.from(userTrackData?['tracks'] ?? []);

        // Filter out the track with the specified trackId
        final updatedTracks =
            tracks.where((track) => track['track_id'] != trackId).toList();

        // Update the UserTracks document with the filtered tracks
        batch.update(userTrackRef, {'tracks': updatedTracks});
      }

      // Commit the batch operation
      await batch.commit();

      print(
          "Track and associated user track deleted successfully for user: $userId.");
    } catch (e) {
      print("Failed to delete track for user: $e");
      rethrow;
    }
  }

  /// 사용자의 트랙 목록 가져오기
  Future<Map<String, List<RouteModel>>> fetchTracks(String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // UserTracks에서 사용자의 트랙 ID 가져오기
    final userTracksDoc =
        await _firestore.collection('UserTracks').doc(userId).get();

    if (!userTracksDoc.exists) {
      return {'myTracks': [], 'participatedTracks': []};
    }

    final tracks = userTracksDoc['tracks'] as List<dynamic>;
    List<String> myTrackIds = [];
    List<String> participatedTrackIds = [];

    for (final track in tracks) {
      final isMyTrack = track['is_my_track'] as bool;
      final trackId = track['track_id'] as String;

      if (isMyTrack) {
        myTrackIds.add(trackId);
      } else {
        participatedTrackIds.add(trackId);
      }
    }

    print("My tracks: $myTrackIds");
    print("Participated tracks: $participatedTrackIds");

    // Tracks 컬렉션에서 트랙 세부 정보 가져오기
    List<RouteModel> myTracks = [];
    List<RouteModel> participatedTracks = [];

    for (String trackId in myTrackIds) {
      final trackDoc = await _firestore.collection('Tracks').doc(trackId).get();
      if (trackDoc.exists) {
        myTracks.add(RouteModel.fromFirestore(trackId, trackDoc.data()!));
      }
    }

    for (String trackId in participatedTrackIds) {
      final trackDoc = await _firestore.collection('Tracks').doc(trackId).get();
      if (trackDoc.exists) {
        participatedTracks
            .add(RouteModel.fromFirestore(trackId, trackDoc.data()!));
      }
    }

    return {'myTracks': myTracks, 'participatedTracks': participatedTracks};
  }

  Future<bool> getTrackPublicStatus(String trackId) async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('Tracks')
          .doc(trackId)
          .get();

      if (document.exists) {
        final isPublic = document.data()?['is_public'] ?? false;
        print("Track ID: $trackId, is_public: $isPublic"); // 값 출력
        return isPublic;
      } else {
        print("Track not found for ID: $trackId");
        throw Exception("Track not found");
      }
    } catch (e) {
      print("Error fetching track public status: $e");
      throw e;
    }
  }
}
