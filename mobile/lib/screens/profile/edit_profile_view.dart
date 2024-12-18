import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("プロファイルを編集"),
      ),
      body: Center(
        child: const Text(
          "ここでプロファイルを編集できます。",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
