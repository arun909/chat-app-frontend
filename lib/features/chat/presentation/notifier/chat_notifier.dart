import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/chat_service.dart';
import 'chat_state.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final String _otherUserId;
  final String? _token;

  String? _conversationId;

  ChatNotifier(this._chatService, this._otherUserId, this._token)
      : super(const ChatLoading()) {
    _initConversation();
  }

  Future<void> _initConversation() async {
    state = const ChatLoading();
    try {
      _conversationId = await _chatService.getOrCreateConversation(
        _otherUserId,
        token: _token,
      );
      await _fetchMessages();
    } catch (e) {
      state = ChatError(e.toString());
    }
  }

  Future<void> _fetchMessages() async {
    if (_conversationId == null) return;
    try {
      final messages = await _chatService.getMessages(_conversationId!, token: _token);
      state = ChatSuccess(messages: messages);
    } catch (e) {
      state = ChatError(e.toString());
    }
  }

  Future<void> getMessages() async {
    state = const ChatLoading();
    await _initConversation();
  }

  Future<void> sendMessage(String text) async {
    if (_conversationId == null) return;
    if (state is ChatSuccess) {
      final currentState = state as ChatSuccess;
      state = currentState.copyWith(isSending: true);

      try {
        final newMessage = await _chatService.sendMessage(
          _conversationId!,
          text,
          token: _token,
        );
        state = currentState.copyWith(
          messages: [...currentState.messages, newMessage],
          isSending: false,
        );
      } catch (e) {
        // Restore the old state with an error flag so user can retry
        state = currentState.copyWith(isSending: false);
        rethrow;
      }
    }
  }
}
