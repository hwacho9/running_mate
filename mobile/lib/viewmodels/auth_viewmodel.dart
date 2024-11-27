import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  /// 로그인 여부 확인
  bool get isLoggedIn => _user != null;

  /// 회원가입
  Future<void> signup(String email, String password) async {
    try {
      _user = await _authService.signup(email, password);
      notifyListeners();
    } catch (e) {
      print("Signup Error: $e");
      rethrow; // 에러를 호출자에게 전달
    }
  }

  /// 로그인
  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
    } catch (e) {
      print("Login Error: $e");
      rethrow; // 에러를 호출자에게 전달
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      print("Logout Error: $e");
      rethrow; // 에러를 호출자에게 전달
    }
  }

  /// 현재 사용자 로드
  void loadCurrentUser() {
    try {
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      print("Load Current User Error: $e");
    }
  }
}
