import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/data/regions.dart';
import 'package:running_mate/screens/home/home_view.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';
import 'package:running_mate/widgets/inputField/DropdownButtonFormField.dart';
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
              labelText: "ニックネーム",
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            DropdownFormField(
              labelText: "地域",
              value:
                  regionController.text.isEmpty ? null : regionController.text,
              items: regions,
              onChanged: (String? newValue) {
                regionController.text = newValue ?? "";
              },
            ),
            const SizedBox(height: 16),
            DropdownFormField(
              labelText: "性別",
              value:
                  genderController.text.isEmpty ? null : genderController.text,
              items: const ["男性", "女性", "その他"],
              onChanged: (String? newValue) {
                genderController.text = newValue ?? "";
              },
            ),
            const SizedBox(height: 16),
            InputFormField(
              controller: ageController,
              labelText: "年齢",
              hintText: "年齢を入力してください", // 힌트 텍스트
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
              ],
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
