import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/running_status_provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/home/widgets/MiniMap.dart';
import 'package:running_mate/screens/profile/profile_view.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final viewmodel = context.watch<RunningViewModel>();
    final status = context.watch<RunningStatusProvider>();

    print(viewmodel.coordinates);
    print(viewmodel.totalPauseTime);
    print(status.isRunning);
    print(status.isPaused);

    if (authViewModel.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ホーム画面"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileView()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
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
              "こんにちは, ${authViewModel.user?.nickname ?? ""}さん!",
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
            const Divider(),
            const SizedBox(height: 16),
            const Text("今日も走りましょう!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const MiniMap(), // MiniMap 컴포넌트 사용
            const SizedBox(height: 32),
            const Text(
              "앱 기능",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
