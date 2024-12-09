import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/auth/signup_view2.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';
import 'package:running_mate/widgets/inputField/InputFormField.dart';

class SignupView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputFormField(
              controller: emailController,
              labelText: "メールアドレス",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            InputFormField(
              controller: passwordController,
              labelText: "パスワード",
              isPassword: true,
            ),
            const SizedBox(height: 20),
            RectangleButton(
              text: "次へ",
              onPressed: () async {
                final authViewModel = context.read<AuthViewModel>();
                try {
                  await authViewModel.signup(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (authViewModel.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupView2(),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("회원가입 실패: ${e.toString()}")),
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
