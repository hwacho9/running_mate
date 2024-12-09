import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/nav_page.dart';
import 'package:running_mate/screens/auth/signup_view.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';
import 'package:running_mate/widgets/inputField/InputFormField.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputFormField(
              controller: emailController,
              labelText: "이메일",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            InputFormField(
              controller: passwordController,
              labelText: "비밀번호",
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authViewModel = context.read<AuthViewModel>();
                try {
                  await authViewModel.login(
                    emailController.text,
                    passwordController.text,
                  );
                  if (authViewModel.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const NavPage()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인 실패: ${e.toString()}")),
                  );
                }
              },
              child: const Text("로그인"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupView()),
                );
              },
              child: const Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
