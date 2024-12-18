import 'package:flutter/material.dart';
import 'sns_search_view.dart';

class SnsView extends StatelessWidget {
  const SnsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SNS'), actions: [
        IconButton(
          icon: const Icon(Icons.search), // 검색 이모티콘
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SnsSearchView()),
            );
          },
        ),
      ]),
      body: const Center(
        child: Text(
          'SNS 메인 화면입니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
