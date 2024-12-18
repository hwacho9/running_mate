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
  final double participantsCcount;
  final bool isPublic;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.distance,
    this.createdAt,
    this.region,
    this.participantsCcount = 1,
    this.isPublic = false,
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
      participantsCcount: (data['participants_count'] as num).toDouble(),
      isPublic: data['is_public'] as bool,
    );
  }
}
