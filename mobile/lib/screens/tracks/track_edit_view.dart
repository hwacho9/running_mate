import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/track_edit_view_model.dart';

class TrackEditView extends StatelessWidget {
  final String trackId;

  const TrackEditView({super.key, required this.trackId});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TrackEditViewModel>();

    // 새로운 트랙 ID로 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchInitialPublicStatus(trackId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Track"),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Public Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Make track public:",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: viewModel.isPublic,
                        onChanged: (value) {
                          viewModel.updatePublicStatus(trackId, value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await viewModel.deleteTrack(trackId);
                      if (result) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Track deleted successfully."),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to delete track."),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Delete Track"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }
}
