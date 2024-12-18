import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/viewmodels/sns_search_view_model.dart';
import 'package:running_mate/screens/profile/profile_view.dart';

class SnsSearchView extends StatelessWidget {
  const SnsSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SnsSearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ユーザー名を検索',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) => viewModel.searchUsers(query),
            ),
          ),
          const Divider(),
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.searchResults.isEmpty
                  ? const Center(child: Text('検索結果がありません.'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = viewModel.searchResults[index];
                          print(user);
                          return ListTile(
                            title: Text(user['nickname']),
                            subtitle: Text(user['email']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileView(
                                    userId: user['id'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
