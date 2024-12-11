import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<LatLng> coordinates;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
  });

  factory RouteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return RouteModel(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      coordinates: (data['coordinates'] as List)
          .map((point) => LatLng(
                (point['lat'] as num).toDouble(),
                (point['lng'] as num).toDouble(),
              ))
          .toList(),
    );
  }
}
