import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 회원가입
  Future<UserModel?> signup(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return UserModel(
          uid: user.uid,
          email: user.email ?? "", // null 방지
        );
      }
      return null;
    } catch (e) {
      print("Signup Error: $e");
      rethrow;
    }
  }

  // 추가 정보 저장
  Future<void> saveAdditionalDetails({
    required String uid,
    required String nickname,
    required String region,
    required String gender,
    required int age,
  }) async {
    try {
      await _firestore.collection('Users').doc(uid).update({
        'nickname': nickname,
        'region': region,
        'gender': gender,
        'age': age,
      });
    } catch (e) {
      print("Save Additional Details Error: $e");
      rethrow;
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
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? "");
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // 현재 사용자
  Future<UserModel?> get currentUser async {
    User? firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('Users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data();
          return UserModel(
            uid: firebaseUser.uid,
            email: data?['email'] ?? firebaseUser.email ?? "",
            nickname: data?['nickname'],
            region: data?['region'],
            gender: data?['gender'],
            age: data?['age'],
          );
        } else {
          print("User document not found!");
        }
      } catch (e) {
        print("Error fetching current user: $e");
      }
    }
    return null;
  }
}
