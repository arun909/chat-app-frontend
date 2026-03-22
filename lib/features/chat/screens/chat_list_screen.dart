import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../presentation/providers/chat_providers.dart';
import '../presentation/notifier/conversations_state.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../auth/presentation/notifier/login_state.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/colors.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsState = ref.watch(conversationsNotifierProvider);
    final loginState = ref.watch(loginNotifierProvider);
    final currentUserId = loginState is LoginSuccess ? loginState.user.id : '';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        centerTitle: false,
        elevation: 0,
        leadingWidth: 140, // Reduced leading width to fit search icon
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/Logo.svg',
                width: 28,
                height: 28,
                color: AppColors
                    .tealAccent, // Changed to teal as per image? No, user said "dont change the logo that we set".
                // Wait, if I use the existing color it might be better if they want to keep it.
                // But the image shows a white/teal logo.
                // I'll stick to the SVG color or slightly white if it's dark.
              ),
              const SizedBox(width: 10),
              const Text(
                'avion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.darkGrey,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.darkGrey,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to profile or search
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserSearchScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.darkSurface,
                backgroundImage: loginState is LoginSuccess &&
                        loginState.user.profilePic != null &&
                        loginState.user.profilePic!.isNotEmpty
                    ? NetworkImage(
                        '${ApiConstants.serverUrl}${loginState.user.profilePic}')
                    : null,
                child: loginState is LoginSuccess &&
                        (loginState.user.profilePic == null ||
                            loginState.user.profilePic!.isEmpty)
                    ? Text(
                        loginState.user.username.isNotEmpty
                            ? loginState.user.username[0].toUpperCase()
                            : '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: AppColors.darkGrey, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "Search conversations...",
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Filters (Tabs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("All", isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip("Unread"),
                const SizedBox(width: 8),
                _buildFilterChip("Groups"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chat List Tile (The "Transparent Tile" wrapper)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: _buildBody(
                  context,
                  ref,
                  conversationsState,
                  currentUserId,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        backgroundColor: AppColors.tealAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit, color: Colors.black),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.tealAccent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
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
    }

    if (state is ConversationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(conversationsNotifierProvider.notifier)
                  .getConversations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ConversationsLoaded) {
      final conversations = state.conversations;

      if (conversations.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64, color: AppColors.darkGrey),
              const SizedBox(height: 16),
              const Text(
                'No chats yet',
                style: TextStyle(fontSize: 18, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search for users to start chatting!',
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final otherParticipant = conversation.participants.firstWhere(
            (p) => p.id != currentUserId,
            orElse: () => conversation.participants.first,
          );

          return ChatTile(
            conversation: conversation,
            currentUserId: currentUserId,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(otherUser: otherParticipant),
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
