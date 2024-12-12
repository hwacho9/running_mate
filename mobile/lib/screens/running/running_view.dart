// running_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/running_result_view.dart';
import 'package:running_mate/utils/direction_util.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';

class RunningView extends StatefulWidget {
  const RunningView({super.key});

  @override
  State<RunningView> createState() => _RunningViewState();
}

class _RunningViewState extends State<RunningView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RunningViewModel>();
      viewModel.startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunningViewModel>();

    if (viewModel.currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print(viewModel.coordinates);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  viewModel.currentPosition ?? const LatLng(34.70, 135.2),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: viewModel.coordinates
                        .map((coord) => LatLng(
                            coord['lat'] as double, coord['lng'] as double))
                        .toList(),
                    strokeWidth: 4.0,
                    color: Colors.red,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: viewModel.currentPosition!,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: DirectionUtil.headingToRadians(viewModel.heading),
                      child: const Icon(
                        Icons.navigation,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: CircleFloatingActionButton(
                backgroundColor:
                    viewModel.isPaused ? Colors.green : Colors.orange,
                size: 72.0,
                onPressed: () {
                  if (viewModel.isPaused) {
                    viewModel.resumeTracking();
                  } else {
                    viewModel.pauseTracking();
                  }
                },
                icon: viewModel.isPaused ? Icons.play_arrow : Icons.pause,
                tooltip: viewModel.isPaused ? 'Resume' : 'Pause',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CircleFloatingActionButton(
        onPressed: () {
          if (!viewModel.isPaused) {
            viewModel.pauseTracking(); // 완료 버튼을 눌러도 일시정지
          }
          final endTime = DateTime.now();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RunningResultView(
                startTime: viewModel.startTime!,
                endTime: endTime,
                coordinates: viewModel.coordinates,
                totalDistance: viewModel.totalDistance,
                pauseTime: viewModel.totalPauseTime,
              ),
            ),
          );
        },
        icon: Icons.check,
      ),
    );
  }
}
