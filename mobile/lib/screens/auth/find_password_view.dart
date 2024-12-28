import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_mate/widgets/Buttons/RectangleButton.dart';

class FindPasswordView extends StatefulWidget {
  const FindPasswordView({Key? key}) : super(key: key);

  @override
  _FindPasswordViewState createState() => _FindPasswordViewState();
}

class _FindPasswordViewState extends State<FindPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar('メールアドレスを入力してください。');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackbar('パスワードリセットメールを送信しました。');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('そのメールアドレスのユーザーが見つかりません。');
      } else {
        _showSnackbar('エラーが発生しました。もう一度お試しください。');
      }
    } catch (e) {
      _showSnackbar('エラーが発生しました。もう一度お試しください。');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスワードを忘れた場合'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '登録済みのメールアドレスを入力してください。\nパスワードリセットメールを送信します。',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: RectangleButton(
                onPressed: _isLoading ? null : _sendPasswordResetEmail,
                text: 'パスワードリセットメールを送信',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
