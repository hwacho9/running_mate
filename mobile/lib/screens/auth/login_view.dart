import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/nav_page.dart';
import 'package:running_mate/screens/auth/signup_view.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';
import 'package:running_mate/widgets/inputField/InputFormField.dart';

// ignore: must_be_immutable
class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン"),
        automaticallyImplyLeading: false,
      ),
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
              text: "ログイン",
              isLoading: isLoading,
              isDisabled: isLoading,
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
                    SnackBar(content: Text("ログイン失敗: ${e.toString()}")),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            RectangleButton(
              color: Colors.white,
              textColor: Colors.black,
              text: "アカウントを作成する",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
