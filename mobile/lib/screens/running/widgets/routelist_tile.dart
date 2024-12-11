import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:running_mate/screens/running/route_detail_page.dart';

class RouteListTile extends StatelessWidget {
  final String name;
  final double distance;
  final List<LatLng> coordinates;

  const RouteListTile({
    Key? key,
    required this.name,
    required this.distance,
    required this.coordinates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(
        distance >= 1000
            ? '${(distance / 1000).toStringAsFixed(1)} km'
            : '${distance.toStringAsFixed(2)} m',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailPage(
              routeName: name,
              routePoints: coordinates,
            ),
          ),
        );
      },
    );
  }
}
