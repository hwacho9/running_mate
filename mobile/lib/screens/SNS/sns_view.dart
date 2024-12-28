import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/location_provider.dart';
import 'package:running_mate/screens/SNS/sns_search_view.dart';
import 'package:running_mate/screens/SNS/widgets/current_region_runners_card.dart';
import 'package:running_mate/screens/SNS/widgets/friend_list_tile.dart';
import 'package:running_mate/screens/SNS/widgets/popular_track_card.dart';
import 'package:running_mate/viewmodels/sns_view_model.dart';

class SnsView extends StatefulWidget {
  const SnsView({super.key});

  @override
  State<SnsView> createState() => _SnsViewState();
}

class _SnsViewState extends State<SnsView> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String currentRegion = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();

      if (locationProvider.region.isNotEmpty) {
        setState(() {
          currentRegion = locationProvider.region;
        });

        context.read<SnsViewModel>().loadSNSData(currentRegion, userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snsViewModel = context.watch<SnsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SnsSearchView()),
              );
            },
          ),
        ],
      ),
      body: snsViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentRegionRunnersCard(
                      region: currentRegion,
                      runnersCount: snsViewModel.currentRegionRunners,
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          '人気トラック',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snsViewModel.popularTracks.length,
                        itemBuilder: (context, index) {
                          final track = snsViewModel.popularTracks[index];
                          return PopularTrackCard(track: track);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          '走ってる友達',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: snsViewModel.runningFriends
                          .map((friend) => FriendListTile(friend: friend))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
