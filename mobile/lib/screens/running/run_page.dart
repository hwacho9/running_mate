import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/running/save_routedetail_view.dart';
import 'package:running_mate/viewmodels/RunViewModel.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:running_mate/utils/direction_util.dart'; // 새 유틸리티 파일 import

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSubscription;
  double _heading = 0.0;

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

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Your Route'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Saveroutedetailview(
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
              initialCenter: viewModel.currentPosition ?? LatLng(34.70, 135.2),
              initialZoom: 18.0,
              onTap: (tapPosition, latLng) {
                viewModel.addRoutePoint(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: viewModel.routePoints,
                    strokeWidth: 4.0,
                    color: Colors.red,
                  ),
                ],
              ),
              if (viewModel.currentPosition != null)
                MarkerLayer(
                  markers: [
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
                  ],
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 45.0), // 버튼 위로 올리기
              child: FloatingActionButton(
                onPressed: () {
                  // 스타트 버튼 동작
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RunningView(), // 새 런닝 페이지
                    ),
                  );
                },
                child: const Icon(Icons.play_arrow),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.clearRoute,
        child: const Icon(Icons.clear),
      ),
    );
  }
}
