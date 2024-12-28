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
  late final MapController _mapController;
  bool _keepCentered = true;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RunningViewModel>();
      final statusProvider = context.read<RunningStatusProvider>();

      if (widget.routePoints != null) {
        viewModel.loadRoutePoints(widget.routePoints!);
      } else {
        viewModel.startTracking(context);
      }

      if (statusProvider.isPaused) {
        viewModel.pauseTracking(context);
      } else if (statusProvider.isRunning) {
        viewModel.resumeTracking(context);
      } else {
        viewModel.startTracking(context);
      }

      debugPrint('trackId: ${widget.trackId}');
      // 다른 사용자 기록 로드 및 재생 시작
      if (widget.trackId != null) {
        // 플레이 시작 시간 초기화 및 사용자 경로 로드
        viewModel.playStartTime = DateTime.now();
        viewModel.loadOtherUserRecords(widget.trackId!).then((_) {
          viewModel.startReplay(); // 기록 재생 시작
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = context.read<RunningViewModel>();
    if (state == AppLifecycleState.paused) {
      viewModel.pauseTracking(context);
    } else if (state == AppLifecycleState.resumed) {
      viewModel.resumeTracking(context);
    }
  }

  @override
  void dispose() {
    final viewModel = context.read<RunningViewModel>();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleCentering() {
    setState(() {
      _keepCentered = !_keepCentered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunningViewModel>();
    final isPaused = context.watch<RunningStatusProvider>().isPaused;

    if (viewModel.currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Update map position only if the map is initialized
    if (_keepCentered && _mapInitialized && viewModel.currentPosition != null) {
      _mapController.move(viewModel.currentPosition!, 18.0);
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Running Tracker'),
          actions: [
            IconButton(
              icon: Icon(
                _keepCentered ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: _keepCentered ? Colors.blue : Colors.grey,
              ),
              onPressed: _toggleCentering,
            ),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    viewModel.currentPosition ?? const LatLng(34.70, 135.2),
                initialZoom: 18.0,
                onMapReady: () {
                  setState(() {
                    _mapInitialized = true;
                  });
                },
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture && _keepCentered) {
                    setState(() {
                      _keepCentered = false;
                    });
                  }
                },
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
                    // 다른 사용자의 위치 마커 추가
                    if (widget.trackId != null)
                      ...viewModel.otherUserLocations.map(
                        (userLocation) {
                          final location = userLocation['location'] as LatLng?;
                          return Marker(
                            point: location ?? LatLng(0, 0),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.green,
                              size: 30,
                            ),
                          );
                        },
                      ).toList(),
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
              viewModel.pauseTracking(context);
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
