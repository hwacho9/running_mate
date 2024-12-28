import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/tracks/track_edit_view.dart';
import 'package:running_mate/viewmodels/track_specific_view_model.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/format.dart';

class TrackSpecificView extends StatefulWidget {
  final String trackId;
  final String name;
  final String description;
  final double distance;
  final String region;
  final DateTime createdAt;
  final List<Map<String, dynamic>> routePoints;
  final double? participants;

  const TrackSpecificView({
    super.key,
    required this.trackId,
    required this.name,
    required this.description,
    required this.distance,
    required this.region,
    required this.createdAt,
    required this.routePoints,
    this.participants,
  });

  @override
  State<TrackSpecificView> createState() => _TrackSpecificViewState();
}

class _TrackSpecificViewState extends State<TrackSpecificView> {
  bool isCreator = false; // 현재 사용자가 트랙의 creator인지 확인
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsCreator();
  }

  // TODO 1: refactoring
  Future<void> _checkIfUserIsCreator() async {
    try {
      // Firestore에서 트랙의 creator_id 가져오기
      final trackDoc = await FirebaseFirestore.instance
          .collection('Tracks')
          .doc(widget.trackId)
          .get();

      if (trackDoc.exists) {
        final creatorId = trackDoc.data()?['creator_id'];
        if (creatorId == currentUserId) {
          setState(() {
            isCreator = true; // 현재 사용자가 creator인 경우 true
          });
        }
      }
    } catch (e) {
      print("Error checking creator: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TrackSpecificViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackEditView(
                      trackId: widget.trackId,
                      userId: currentUserId!,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultMinimap(
                  routePoints: widget.routePoints,
                  initialZoom: 14,
                ),
                const SizedBox(height: 16),
                // 참가자 표시
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orangeAccent,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // 아이콘과 숫자 간격
                    Text(
                      "${widget.participants?.toStringAsFixed(0) ?? 0}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      " ${widget.region}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "生成日: ${formatDate(widget.createdAt)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  formatDistance(widget.distance),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  " ${widget.description}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 8),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: CircleFloatingActionButton(
                backgroundColor: Colors.orange,
                size: 72.0,
                onPressed: () async {
                  if (!isCreator) {
                    await model.joinTrack(currentUserId!, widget.trackId);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RunningView(
                        routePoints: widget.routePoints,
                        trackId: widget.trackId,
                      ),
                    ),
                  );
                },
                icon: Icons.play_arrow,
                tooltip: isCreator ? 'Start' : 'Join & Start',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
