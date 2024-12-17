import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/save_track_detail_view.dart';
import 'package:running_mate/widgets/result_minimap.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:running_mate/viewmodels/running_result_view_model.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import 'package:running_mate/screens/running/widgets/running_statistics_section.dart';
import 'package:running_mate/screens/running/widgets/running_buttons_section.dart';

class RunningResultView extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final Duration pauseTime;
  final List<Map<String, dynamic>> coordinates;
  final double totalDistance;

  const RunningResultView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.pauseTime,
    required this.coordinates,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunningResultViewModel>();
    final runningViewModel = context.watch<RunningViewModel>();
    final duration = endTime.difference(startTime) - pauseTime;
    final averageSpeed = totalDistance > 0
        ? (totalDistance / (duration.inSeconds / 3600))
        : 0.0; // 平均速度 (km/h)

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランニング記録'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Text("再開"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            // 統計情報セクション
            RunningStatisticsSection(
              totalDistance: totalDistance,
              duration: duration,
              averageSpeed: averageSpeed,
              pauseTime: pauseTime,
              startTime: startTime,
              endTime: endTime,
            ),
            const SizedBox(height: 16),
            // マップビュー
            ResultMinimap(routePoints: coordinates, initialZoom: 18),
            const SizedBox(height: 25),
            // ボタンセクション
            RunningButtonsSection(
              onSaveRecord: () async {
                final authViewModel = context.read<AuthViewModel>();
                final userId = authViewModel.user?.uid ?? '';

                if (userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ユーザーIDがありません')),
                  );
                  return;
                }

                try {
                  await viewModel.saveUserRecord(
                    userId: userId,
                    startTime: startTime,
                    endTime: endTime,
                    pauseTime: pauseTime,
                    distance: totalDistance,
                    coordinates: coordinates,
                  );
                  runningViewModel.stopTracking(context); // 追跡終了
                  Navigator.pushReplacementNamed(context, '/');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ランニング記録が保存されました')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('記録の保存に失敗しました')),
                  );
                }
              },
              onSaveTrack: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaveTrackdetailview(
                      onSave: (name, description) async {
                        final authViewModel = context.read<AuthViewModel>();
                        final userId = authViewModel.user?.uid ?? '';

                        if (userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ユーザーIDがありません')),
                          );
                          return;
                        }

                        try {
                          if (coordinates.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('利用可能な座標がありません')),
                            );
                            return;
                          }

                          final firstPoint = coordinates.first;
                          final region =
                              await RegionHelper.getRegionFromCoordinates(
                            firstPoint['lat'],
                            firstPoint['lng'],
                          );

                          final translatedRegion =
                              CheckLanguageUtil.isKoreanRegion(region)
                                  ? convertKoreanToJapanese(region)
                                  : region;

                          await viewModel.saveTrackWithUserRecord(
                            userId: userId,
                            startTime: startTime,
                            endTime: endTime,
                            pauseTime: pauseTime,
                            distance: totalDistance,
                            coordinates: coordinates,
                            trackName: name,
                            description: description,
                            region: translatedRegion,
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('トラックとユーザー記録が正常に保存されました'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('トラックと記録の保存に失敗しました')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () {
                runningViewModel.stopTracking(context); // 기록 추적 종료
                Navigator.pushReplacementNamed(context, '/'); // 홈으로 이동
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade300, // 텍스트 색상
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('記録を破棄する'),
            ),
          ],
        ),
      ),
    );
  }
}
