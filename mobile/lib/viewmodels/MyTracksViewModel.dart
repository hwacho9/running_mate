import 'package:flutter/foundation.dart';
import 'package:running_mate/models/RouteModel.dart';
import 'package:running_mate/services/Trackservice.dart';

class MyTracksViewModel extends ChangeNotifier {
  final Trackservice _routeService;

  MyTracksViewModel(this._routeService);

  List<RouteModel> _routes = [];
  bool _isLoading = false;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;

  Future<void> loadRoutes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _routes = await _routeService.fetchTracks();
    } catch (e) {
      print("Error loading routes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
