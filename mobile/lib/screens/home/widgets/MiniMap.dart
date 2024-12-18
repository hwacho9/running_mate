import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MiniMap extends StatefulWidget {
  const MiniMap({super.key});

  @override
  _MiniMapState createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  LatLng? _currentPosition;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition!, 13.0);
        print(_currentPosition);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? LatLng(34.7, 135.2),
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // 모든 상호작용 비활성화
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
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
          // 지도 위를 덮는 투명 오버레이
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/run');
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
