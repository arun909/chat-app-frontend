import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/chat_service.dart';
import 'conversations_state.dart';

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatService _chatService;
  final String? _token;

  ConversationsNotifier(this._chatService, this._token)
      : super(const ConversationsInitial()) {
    getConversations();
  }

  Future<void> getConversations() async {
    state = const ConversationsLoading();
    try {
      final conversations = await _chatService.getConversations(token: _token);
      state = ConversationsLoaded(conversations);
    } catch (e) {
      state = ConversationsError(e.toString());
    }
  }
}
