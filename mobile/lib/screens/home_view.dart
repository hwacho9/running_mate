import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("홈 화면"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              Navigator.pop(context); // 로그인 화면으로 이동
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "안녕하세요, ${authViewModel.user?.email ?? "사용자"}님!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "현재 사용자 정보:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "UID: ${authViewModel.user?.uid ?? "알 수 없음"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Email: ${authViewModel.user?.email ?? "알 수 없음"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            Divider(),
            Text(
              "앱 기능",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.person),
              label: Text("프로필 보기"),
              onPressed: () {
                // 프로필 보기 화면으로 이동 (구현 필요)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("프로필 보기 기능 준비 중")),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.settings),
              label: Text("설정"),
              onPressed: () {
                // 설정 화면으로 이동 (구현 필요)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("설정 기능 준비 중")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
