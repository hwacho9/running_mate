import 'package:flutter/material.dart';

class SharedRoutesPage extends StatelessWidget {
  const SharedRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Routes'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const Text("내 주변 트랙, 현별 트랙, 인기 트랙"),
          const Center(
            child: Text('List of shared routes will be displayed here.'),
          ),
        ],
      ),
    );
  }
}
