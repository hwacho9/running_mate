import 'package:flutter/material.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';

class Saveroutedetailview extends StatefulWidget {
  final void Function(String name, String description) onSave;

  const Saveroutedetailview({super.key, required this.onSave});

  @override
  _SaveroutedetailviewState createState() => _SaveroutedetailviewState();
}

class _SaveroutedetailviewState extends State<Saveroutedetailview> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                final name = _nameController.text.trim();
                final description = _descriptionController.text.trim();

                if (name.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Save and return
                widget.onSave(name, description);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
