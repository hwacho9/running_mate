import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/home/home_view.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';
import 'package:running_mate/widgets/inputField/InputFormField.dart';

class SignupView2 extends StatelessWidget {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("추가 정보 입력"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputFormField(
              controller: nicknameController,
              labelText: "닉네임",
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            InputFormField(
              controller: regionController,
              labelText: "지역",
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(labelText: "성별"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "나이"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            RectangleButton(
              text: "アカウントを作成",
              onPressed: () async {
                final nickname = nicknameController.text.trim();
                final region = regionController.text.trim();
                final gender = genderController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;

                if (nickname.isNotEmpty &&
                    region.isNotEmpty &&
                    gender.isNotEmpty &&
                    age > 0) {
                  final authViewModel = context.read<AuthViewModel>();
                  try {
                    authViewModel.saveAdditionalDetails(
                      nickname,
                      region,
                      gender,
                      age,
                    );
                    // HomeView로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeView()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("정보 저장 실패: ${e.toString()}")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("모든 필드를 올바르게 입력해주세요.")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
