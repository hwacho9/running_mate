import 'package:flutter/material.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';

class RunningButtonsSection extends StatelessWidget {
  final VoidCallback onSaveRecord;
  final VoidCallback onSaveTrack;

  const RunningButtonsSection({
    super.key,
    required this.onSaveRecord,
    required this.onSaveTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RectangleButton(
          text: '記録だけ保存',
          onPressed: onSaveRecord,
        ),
        const SizedBox(height: 10),
        RectangleButton(
          text: 'トラックと記録を保存',
          onPressed: onSaveTrack,
        ),
      ],
    );
  }
}
