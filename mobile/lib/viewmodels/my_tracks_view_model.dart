import 'package:flutter/foundation.dart';
import 'package:running_mate/models/route_model.dart';
import 'package:running_mate/services/track_service.dart';

class MyTracksViewModel extends ChangeNotifier {
  final Trackservice _trackService;

  MyTracksViewModel(this._trackService);

  List<RouteModel> _routes = [];
  bool _isLoading = false;

  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;

  Future<void> loadRoutes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _routes = await _trackService.fetchTracks();
    } catch (e) {
      print("Error loading routes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
