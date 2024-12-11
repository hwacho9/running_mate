// views/run_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/RunViewModel.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  _RunPageState createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // initState에서는 Provider에 바로 접근하지 않고,
    // 첫 프레임 렌더링 이후에 Provider에 접근합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final creatorId = authViewModel.user?.uid ?? "";

      final viewModel = context.read<RunViewModel>();
      viewModel.init(creatorId).then((_) {
        if (viewModel.currentPosition != null) {
          _mapController.move(viewModel.currentPosition!, 13.0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RunViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Your Route'),
        actions: [
          IconButton(
            onPressed: () async {
              bool saved = await viewModel.saveRoute();
              if (saved && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route saved successfully!')),
                );
                Navigator.pushNamed(context, '/my-routes');
              }
            },
            icon: const Icon(Icons.save),
            tooltip: 'Save Route',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: viewModel.currentPosition ?? LatLng(34.70, 135.2),
          initialZoom: 15.0,
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
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              ],
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
