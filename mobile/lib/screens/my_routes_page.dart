import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 변환을 위해 필요
import 'route_detail_page.dart';

class MyRoutesPage extends StatefulWidget {
  const MyRoutesPage({super.key});

  @override
  _MyRoutesPageState createState() => _MyRoutesPageState();
}

class _MyRoutesPageState extends State<MyRoutesPage> {
  List<Map<String, dynamic>> _routes = []; // 경로 데이터 저장

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  // 저장된 경로 불러오기
  Future<void> _loadRoutes() async {
    final prefs = await SharedPreferences.getInstance();

    // 저장된 경로 가져오기
    final savedRoutes = prefs.getStringList('routes') ?? [];

    setState(() {
      _routes = savedRoutes
          .map((route) => jsonDecode(route) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routes')),
      body: _routes.isEmpty
          ? const Center(
              child: Text('No routes saved yet.'),
            )
          : ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return ListTile(
                  title: Text(route['name']),
                  subtitle: Text('${route['points'].length} points'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteDetailPage(
                          routeName: route['name'],
                          routePoints: (route['points'] as List)
                              .map((point) => LatLng(point['lat'] as double,
                                  point['lng'] as double))
                              .toList(),
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
