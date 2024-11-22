import 'package:flutter/material.dart';

class SharedRoutesPage extends StatelessWidget {
  const SharedRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Routes')),
      body: const Center(
        child: Text('List of shared routes will be displayed here.'),
      ),
    );
  }
}
