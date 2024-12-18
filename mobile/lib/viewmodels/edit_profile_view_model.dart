import 'package:flutter/foundation.dart';
import 'package:running_mate/services/auth_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false; // 삭제 진행 상태
  bool get isLoading => _isLoading;

  EditProfileViewModel(this._authService);

  Future<void> deleteAccount(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount(uid);
    } catch (e) {
      print("Account deletion failed: $e");
      rethrow; // 실패 시 예외를 다시 던짐
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
