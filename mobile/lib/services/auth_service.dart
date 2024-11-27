import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 회원가입
  Future<UserModel?> signup(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
          uid: userCredential.user?.uid, email: userCredential.user?.email);
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  // 로그인
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(
          uid: userCredential.user?.uid, email: userCredential.user?.email);
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // 현재 사용자
  UserModel? get currentUser {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(uid: user.uid, email: user.email);
    }
    return null;
  }
}
