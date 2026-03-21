import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../auth/presentation/notifier/login_state.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../presentation/notifier/chat_state.dart';
import '../presentation/providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final UserEntity otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider(widget.otherUser.id));
    final loginState = ref.watch(loginNotifierProvider);
    final myId = loginState is LoginSuccess ? loginState.user.id : '';

    if (chatState is ChatSuccess) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.darkSurface,
              backgroundImage: widget.otherUser.profilePic != null &&
                      widget.otherUser.profilePic!.isNotEmpty
                  ? NetworkImage(
                      '${ApiConstants.serverUrl}${widget.otherUser.profilePic}')
                  : null,
              child: (widget.otherUser.profilePic == null ||
                      widget.otherUser.profilePic!.isEmpty)
                  ? Text(
                      widget.otherUser.username.isNotEmpty
                          ? widget.otherUser.username[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: AppColors.tealAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.darkGrey),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessageList(chatState, myId)),
            _buildMessageInput(chatState),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatState state, String myId) {
    if (state is ChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref
                  .read(chatNotifierProvider(widget.otherUser.id).notifier)
                  .getMessages(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ChatSuccess) {
      final messages = state.messages;
      if (messages.isEmpty) {
        return const Center(
          child: Text('No messages yet. Say hi! 👋',
              style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMe = message.senderId == myId;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? AppColors.darkSurface : AppColors.darkSurface,
                border: isMe
                    ? Border.all(color: AppColors.tealAccent.withOpacity(0.3))
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: AppColors.tealAccent,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageInput(ChatState state) {
    final isSending = state is ChatSuccess && state.isSending;
    final hasConversation = state is! ChatLoading && state is! ChatError;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          border: Border(
            top: BorderSide(color: AppColors.darkSurface, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: hasConversation,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hasConversation
                        ? 'Type a message...'
                        : 'Loading chat...',
                    hintStyle: const TextStyle(color: AppColors.darkGrey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.tealAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed:
                    (isSending || !hasConversation) ? null : _sendMessage,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      await ref
          .read(chatNotifierProvider(widget.otherUser.id).notifier)
          .sendMessage(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
