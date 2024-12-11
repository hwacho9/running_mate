import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/MyTracksViewModel.dart';
import 'route_detail_page.dart';

class MyTracksView extends StatefulWidget {
  const MyTracksView({super.key});

  @override
  _MyTracksViewState createState() => _MyTracksViewState();
}

class _MyTracksViewState extends State<MyTracksView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyTracksViewModel>().loadRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyTracksViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Routes')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.routes.isEmpty
              ? const Center(
                  child: Text('No routes saved yet.'),
                )
              : ListView.builder(
                  itemCount: viewModel.routes.length,
                  itemBuilder: (context, index) {
                    final route = viewModel.routes[index];
                    return ListTile(
                      title: Text(route.name),
                      subtitle: Text('${route.coordinates.length} points'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteDetailPage(
                              routeName: route.name,
                              routePoints: route.coordinates,
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
