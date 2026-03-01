import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/notifier/user_search_state.dart';
import '../presentation/providers/chat_providers.dart';
import 'chat_screen.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (query) {
            ref.read(userSearchNotifierProvider.notifier).searchUsers(query);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(UserSearchState state) {
    if (state is UserSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UserSearchError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state is UserSearchSuccess) {
      final users = state.users;
      if (users.isEmpty) {
        return const Center(child: Text('No users found'));
      }

      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(user.username),
            subtitle: Text(user.email),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(otherUser: user),
                ),
              );
            },
          );
        },
      );
    }

    return const Center(
      child: Text(
        'Start typing to search users',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
