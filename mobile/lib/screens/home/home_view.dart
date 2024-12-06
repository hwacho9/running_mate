import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("홈 화면"),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();

              // 로그아웃 후 로그인 화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginView()),
              );
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "현재 사용자 정보:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "UID: ${authViewModel.user?.uid ?? "알 수 없음"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Email: ${authViewModel.user?.email ?? "알 수 없음"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const Text(
              "앱 기능",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("프로필 보기"),
              onPressed: () {
                // 프로필 보기 화면으로 이동 (구현 필요)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("프로필 보기 기능 준비 중")),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("설정"),
              onPressed: () {
                // 설정 화면으로 이동 (구현 필요)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("설정 기능 준비 중")),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text("running"),
              onPressed: () {
                // 설정 화면으로 이동 (구현 필요)
                Navigator.pushNamed(context, '/run');
              },
            ),
          ],
        ),
      ),
    );
  }
}
