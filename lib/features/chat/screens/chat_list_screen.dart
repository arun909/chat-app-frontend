import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/chat_providers.dart';
import '../presentation/notifier/conversations_state.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../auth/presentation/notifier/login_state.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsState = ref.watch(conversationsNotifierProvider);
    final loginState = ref.watch(loginNotifierProvider);
    final currentUserId = loginState is LoginSuccess ? loginState.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, conversationsState, currentUserId),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ConversationsState state,
    String currentUserId,
  ) {
    if (state is ConversationsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ConversationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(conversationsNotifierProvider.notifier).getConversations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state is ConversationsLoaded) {
      final conversations = state.conversations;
      if (conversations.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No chats yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Search for users to start chatting!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final otherParticipantName =
              conversation.getOtherParticipantName(currentUserId);
          final lastMessage = conversation.lastMessage;
          final otherParticipant = conversation.participants.firstWhere(
            (p) => p.id != currentUserId,
            orElse: () => conversation.participants.first,
          );

          return ListTile(
            leading: CircleAvatar(
              child: Text(otherParticipantName[0].toUpperCase()),
            ),
            title: Text(
              otherParticipantName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              lastMessage?.text ?? 'Started a conversation',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(otherUser: otherParticipant),
                ),
              );
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
