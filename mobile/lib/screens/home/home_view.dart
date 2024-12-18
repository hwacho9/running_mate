import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/running_status_provider.dart';
import 'package:running_mate/screens/home/widgets/MiniMap.dart';
import 'package:running_mate/screens/home/widgets/stat_grid.dart';
import 'package:running_mate/screens/profile/profile_view.dart';
import 'package:running_mate/viewmodels/home_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final homeViewModel = context.read<HomeViewModel>();
      homeViewModel.loadUserStats(authViewModel.user!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();
    final runningStatus = context.watch<RunningStatusProvider>();

    if (authViewModel.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    print("isRunning :  ${runningStatus.isRunning}");
    print("isPaused : ${runningStatus.isPaused}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("ホーム画面"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileView(
                          userId: authViewModel.user!.uid,
                        )),
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
            homeViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : homeViewModel.userStats != null
                    ? StatGrid(
                        totalRunCount: homeViewModel.userStats!.totalRunCount,
                        totalRunDays: homeViewModel.userStats!.totalRunDays,
                        currentStreak: homeViewModel.userStats!.currentStreak,
                        totalDistance: homeViewModel.userStats!.totalDistance,
                      )
                    : const StatGrid(
                        totalRunCount: 0,
                        totalRunDays: 0,
                        currentStreak: 0,
                        totalDistance: 0),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text("今日も走りましょう!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const MiniMap(),
          ],
        ),
      ),
    );
  }
}
