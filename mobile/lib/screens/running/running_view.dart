import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/running_result_view.dart';
import 'package:running_mate/utils/direction_util.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';
import 'package:running_mate/provider/running_status_provider.dart';

class RunningView extends StatefulWidget {
  final String? trackId; // 트랙 ID (선택 사항)
  final List<Map<String, dynamic>>? routePoints; // 전달받은 경로 포인트

  const RunningView({super.key, this.trackId, this.routePoints});

  @override
  State<RunningView> createState() => _RunningViewState();
}

class _RunningViewState extends State<RunningView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RunningViewModel>();
      final statusProvider = context.read<RunningStatusProvider>();

      print(widget.trackId);
      print(widget.routePoints);
      if (widget.routePoints != null) {
        // 기존 트랙 로드
        viewModel.loadRoutePoints(widget.routePoints!);
      } else {
        // 새 트래킹 시작
        viewModel.startTracking(context);
      }
      // 런닝 상태를 동기화
      if (statusProvider.isPaused) {
        viewModel.pauseTracking(context);
      } else if (statusProvider.isRunning) {
        viewModel.resumeTracking(context);
      } else {
        viewModel.startTracking(context);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = context.read<RunningViewModel>();
    if (state == AppLifecycleState.paused) {
      viewModel.pauseTracking(context); // 백그라운드 상태 시 일시정지
    } else if (state == AppLifecycleState.resumed) {
      viewModel.resumeTracking(context); // 다시 활성화 시 재개
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunningViewModel>();
    final isPaused = context.watch<RunningStatusProvider>().isPaused;

    // print(viewModel.totalPauseTime);
    if (viewModel.currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/'); // 홈 화면으로 이동
        return false; // 뒤로가기 동작 중단
      },
      child: Scaffold(
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
                if (viewModel.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: viewModel.routePoints,
                        strokeWidth: 4.0,
                        color: Colors.red,
                      ),
                    ],
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: viewModel.coordinates
                          .map((coord) => LatLng(
                              coord['lat'] as double, coord['lng'] as double))
                          .toList(),
                      strokeWidth: 4.0,
                      color: Colors.blue,
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
                        angle:
                            DirectionUtil.headingToRadians(viewModel.heading),
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
                  backgroundColor: isPaused ? Colors.green : Colors.orange,
                  size: 72.0,
                  onPressed: () {
                    if (isPaused) {
                      viewModel.resumeTracking(context);
                    } else {
                      viewModel.pauseTracking(context);
                    }
                  },
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  tooltip: isPaused ? 'Resume' : 'Pause',
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: CircleFloatingActionButton(
          onPressed: () {
            if (!isPaused) {
              viewModel.pauseTracking(context); // 완료 버튼을 눌러도 일시정지
            }
            final endTime = DateTime.now();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RunningResultView(
                  startTime: viewModel.startTime!,
                  trackId: widget.trackId,
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
      ),
    );
  }
}
