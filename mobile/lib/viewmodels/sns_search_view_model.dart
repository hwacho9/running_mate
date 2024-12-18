import 'package:flutter/material.dart';
import 'package:running_mate/services/sns_service.dart';

class SnsSearchViewModel extends ChangeNotifier {
  final SnsService _snsService;

  SnsSearchViewModel(this._snsService);

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _snsService.searchUsers(query);
    } catch (e) {
      print("Error in ViewModel search: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
