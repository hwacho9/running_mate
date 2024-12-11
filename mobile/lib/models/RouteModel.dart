import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<LatLng> coordinates;
  final double distance;
  final DateTime? createdAt;
  final String? region;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.distance,
    this.createdAt,
    this.region,
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
      distance: data['distance'] as double,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      region: data['region'] as String?,
    );
  }
}
