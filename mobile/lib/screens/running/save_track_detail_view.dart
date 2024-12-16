import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/run_view_model.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';

class SaveTrackdetailview extends StatefulWidget {
  final void Function(String name, String description) onSave;

  const SaveTrackdetailview({super.key, required this.onSave});

  @override
  _SaveTrackdetailviewState createState() => _SaveTrackdetailviewState();
}

class _SaveTrackdetailviewState extends State<SaveTrackdetailview> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final runViewModel = context.read<RunViewModel>();
    final runningViewModel = context.watch<RunningViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ルートの詳細'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ルート名',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '詳細',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            RectangleButton(
              text: '保存',
              onPressed: () async {
                final name = _nameController.text.trim();
                final description = _descriptionController.text.trim();

                if (name.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Save the track details
                widget.onSave(name, description);

                // Clear temporary track points in the RunViewModel
                runViewModel.clearRoute();
                await runningViewModel.stopTracking(context); // 追跡終了

                // Navigate to '/' and clear navigation stack
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
