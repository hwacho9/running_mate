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
        final userDocRef = _firestore.collection('Users').doc(user.uid);

        // 사용자 문서 생성 및 초기 데이터 설정
        await userDocRef.set({
          'email': email,
          'uid': user.uid,
          'isRunning': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Following 및 Followers 서브컬렉션 초기화
        final followingRef = userDocRef.collection('Following');
        final followersRef = userDocRef.collection('Followers');

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

  // 계정 삭제
  Future<void> deleteAccount(String uid) async {
    try {
      // Firestore에서 사용자 데이터 삭제
      await _firestore.collection('Users').doc(uid).delete();

      // Firebase Auth에서 사용자 계정 삭제
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }
}
