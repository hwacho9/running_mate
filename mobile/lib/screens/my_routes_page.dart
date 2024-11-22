import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'route_detail_page.dart';

class MyRoutesPage extends StatelessWidget {
  MyRoutesPage({super.key});

  final List<Map<String, dynamic>> mockRoutes = [
    {
      "name": "Morning Run",
      "participants": 5,
      "route": [LatLng(34.7, 135.2), LatLng(34.71, 135.21)]
    },
    {
      "name": "Park Loop",
      "participants": 3,
      "route": [LatLng(34.72, 135.22), LatLng(34.73, 135.23)]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routes')),
      body: ListView.builder(
        itemCount: mockRoutes.length,
        itemBuilder: (context, index) {
          final route = mockRoutes[index];
          return ListTile(
            title: Text(route['name']),
            subtitle: Text('${route['participants']} participants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailPage(
                    routeName: route['name'],
                    participants: route['participants'],
                    routePoints: route['route'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
