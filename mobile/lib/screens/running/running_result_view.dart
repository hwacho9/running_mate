import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/save_routedetail_view.dart';
import 'package:running_mate/utils/check_language_util.dart';
import 'package:running_mate/utils/get_region_util.dart';
import 'package:running_mate/utils/regionConverter.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:running_mate/viewmodels/running_result_view_model.dart';
import 'package:running_mate/screens/running/widgets/result_minimap.dart';

class RunningResultView extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final List<Map<String, dynamic>> coordinates;
  final double totalDistance;

  const RunningResultView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.coordinates,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunningResultViewModel>();
    final duration = endTime.difference(startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Start Time: $startTime'),
            Text('End Time: $endTime'),
            Text('Duration: ${duration.inMinutes} minutes'),
            Text('Total Distance: ${totalDistance.toStringAsFixed(2)} meters'),
            const SizedBox(height: 16),
            const Text(
              'Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ResultMinimap(routePoints: coordinates),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final authViewModel = context.read<AuthViewModel>();
                final userId = authViewModel.user?.uid ?? '';

                if (userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User ID is missing')),
                  );
                  return;
                }

                try {
                  await viewModel.saveUserRecord(
                    userId: userId,
                    startTime: startTime,
                    endTime: endTime,
                    distance: totalDistance,
                    coordinates: coordinates,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User record saved')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save record')),
                  );
                }
              },
              child: const Text('Save User Record'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Saveroutedetailview(
                      onSave: (name, description) async {
                        final authViewModel = context.read<AuthViewModel>();
                        final userId = authViewModel.user?.uid ?? '';

                        if (userId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User ID is missing')),
                          );
                          return;
                        }

                        try {
                          // 리전 정보 가져오기
                          if (coordinates.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No coordinates available')),
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

                          // 저장 로직 실행
                          await viewModel.saveTrackWithUserRecord(
                            userId: userId,
                            startTime: startTime,
                            endTime: endTime,
                            distance: totalDistance,
                            coordinates: coordinates,
                            trackName: name,
                            description: description,
                            region: translatedRegion,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Track and user record saved successfully'),
                            ),
                          );
                          Navigator.pop(context); // 저장 완료 후 이전 화면으로 이동
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Failed to save track and record')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              child: const Text('Save Track and User Record'),
            ),
          ],
        ),
      ),
    );
  }
}
