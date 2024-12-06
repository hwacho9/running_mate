import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/home/home_view.dart';
import 'package:running_mate/viewmodels/auth_viewmodel.dart';

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
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "이메일"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authViewModel = context.read<AuthViewModel>();
                try {
                  await authViewModel.signup(
                    emailController.text,
                    passwordController.text,
                  );
                  if (authViewModel.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeView()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("회원가입 실패: ${e.toString()}")),
                  );
                }
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
