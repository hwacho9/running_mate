class UserModel {
  final String uid;
  final String email;
  final String? nickname;
  final String? region;
  final String? gender;
  final int? age;

  UserModel({
    required this.uid,
    required this.email,
    this.nickname,
    this.region,
    this.gender,
    this.age,
  });

  UserModel copyWith({
    String? nickname,
    String? region,
    String? gender,
    int? age,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      nickname: nickname ?? this.nickname,
      region: region ?? this.region,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }
}
