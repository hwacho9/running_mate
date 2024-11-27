import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              onPressed: () {
                final authViewModel = context.read<AuthViewModel>();
                authViewModel.signup(
                  emailController.text,
                  passwordController.text,
                );
              },
              child: Text("회원가입"),
            ),
          ],
        ),
      ),
    );
  }
}
