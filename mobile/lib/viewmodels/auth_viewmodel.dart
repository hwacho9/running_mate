import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  // 회원가입
  Future<void> signup(String email, String password) async {
    try {
      _user = await _authService.signup(email, password);
      notifyListeners();
    } catch (e) {
      print("Signup Error: $e");
      rethrow;
    }
  }

  // 추가 정보 저장
  Future<void> saveAdditionalDetails(
    String nickname,
    String region,
    String gender,
    int age,
  ) async {
    if (_user == null) {
      throw Exception("User not logged in");
    }

    try {
      await _authService.saveAdditionalDetails(
        uid: _user!.uid,
        nickname: nickname,
        region: region,
        gender: gender,
        age: age,
      );

      // 로컬 상태 업데이트
      _user = _user!.copyWith(
        nickname: nickname,
        region: region,
        gender: gender,
        age: age,
      );
      notifyListeners();
    } catch (e) {
      print("Save Additional Details Error: $e");
      rethrow;
    }
  }

  // 로그인
  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.login(email, password);

      // 로그인 후 추가 정보 로드
      _user = await _authService.currentUser;
      notifyListeners();
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  // 로그아웃
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

  // 현재 사용자 로드
  Future<void> loadCurrentUser() async {
    try {
      _user = await _authService.currentUser;
      notifyListeners();
    } catch (e) {
      print("Error loading current user: $e");
    }
  }
}
