import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<void> signup(String email, String password) async {
    try {
      _user = await _authService.signup(email, password);
      notifyListeners();
    } catch (e) {
      print("Signup Error: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      print("Logout Error: $e");
      rethrow;
    }
  }

  void loadCurrentUser() {
    _user = _authService.currentUser;
    notifyListeners();
  }
}
