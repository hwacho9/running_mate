import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/running/save_track_detail_view.dart';
import 'package:running_mate/viewmodels/run_view_model.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:running_mate/utils/direction_util.dart';
import 'package:running_mate/widgets/Buttons/CircleFloatingActionButton.dart';

class RunView extends StatefulWidget {
  const RunView({super.key});

  @override
  _RunViewState createState() => _RunViewState();
}

class _RunViewState extends State<RunView> {
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSubscription;
  double _heading = 0.0;
  bool _isDrawingMode = false; // 그리기 모드 여부
  List<LatLng> _markers = []; // 마커 리스트
  bool _keepCentered = true;
  bool _mapInitialized = false;

  List<LatLng> _getPolylinePoints() {
    List<LatLng> points = [];
    for (int i = 1; i < _markers.length; i++) {
      points.add(_markers[i - 1]);
      points.add(_markers[i]);
    }
    return points;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final creatorId = authViewModel.user?.uid ?? "";

      final viewModel = context.read<RunViewModel>();
      viewModel.init(creatorId).then((_) {
        if (viewModel.currentPosition != null) {
          _mapController.move(viewModel.currentPosition!, 13.0);
        }
      });

      _startHeadingUpdates();
    });
  }

  void _startHeadingUpdates() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _heading = position.heading; // 방향 값 업데이트
        });
      }
    });
  }

  void _toggleCentering() {
    setState(() {
      _keepCentered = !_keepCentered;
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunViewModel>();

    // Update map position only if the map is initialized
    if (_keepCentered && _mapInitialized && viewModel.currentPosition != null) {
      _mapController.move(viewModel.currentPosition!, 18.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランニング'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            _keepCentered ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: _keepCentered ? Colors.blue : Colors.grey,
          ),
          onPressed: _toggleCentering,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SaveTrackdetailview(
                    onSave: (name, description) async {
                      bool saved = await viewModel.saveRouteWithDetails(
                        name: name,
                        description: description,
                      );
                      if (saved && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Route saved successfully!')),
                        );
                        Navigator.pushNamed(context, '/my-routes');
                      }
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.save),
            tooltip: 'Save Route',
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
              onTap: _isDrawingMode
                  ? (tapPosition, latLng) {
                      setState(() {
                        _markers.add(latLng); // 마커 추가
                        viewModel.addRoutePoint(latLng); // 경로에 추가
                        print(viewModel.routePoints);
                      });
                    }
                  : null, // 그리기 모드에서만 동작
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _getPolylinePoints(), // 경로 계산 함수 호출
                    strokeWidth: 4.0,
                    color: Colors.red,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (viewModel.currentPosition != null)
                    Marker(
                      point: viewModel.currentPosition!,
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: DirectionUtil.headingToRadians(_heading),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                  ..._markers.map((latLng) => Marker(
                        point: latLng,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.place,
                          color: Colors.red,
                          size: 30,
                        ),
                      )),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0), // 버튼 위로 올리기
              child: CircleFloatingActionButton(
                backgroundColor: Colors.orange,
                size: 72.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RunningView(),
                    ),
                  );
                },
                icon: Icons.play_arrow,
                tooltip: 'Start',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 48.0),
              child: CircleFloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_isDrawingMode) {
                      // 드로잉 모드 종료
                      viewModel.clearRoute(); // 루트 초기화
                      _markers.clear(); // 마커 초기화
                    } else {
                      // 드로잉 모드 시작
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('トラックポイントを押してください'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.blue,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 130),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(
                                color: Colors.blueGrey, width: 2),
                          ),
                        ),
                      );
                    }
                    _isDrawingMode = !_isDrawingMode;
                  });
                },
                icon: _isDrawingMode ? Icons.close : Icons.edit,
                tooltip:
                    _isDrawingMode ? 'Exit Drawing Mode' : 'Enter Drawing Mode',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
