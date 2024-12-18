import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/edit_profile_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("プロファイルを編集"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ここでプロファイルを編集できます。",
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "プロファイル編集は追加予定です。",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            viewModel.isLoading
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("アカウント削除"),
                              content: const Text(
                                "アカウントを削除すると、すべてのデータが失われます。本当に削除しますか？",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("キャンセル"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("削除"),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (shouldDelete) {
                        try {
                          await viewModel.deleteAccount(userId);
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false); // 홈으로 이동
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("アカウント削除に失敗しました。"),
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade300, // 텍스트 색상
                      textStyle: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('アカウントを削除する'),
                  ),
          ],
        ),
      ),
    );
  }
}
