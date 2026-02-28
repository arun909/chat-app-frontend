import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/chat_service.dart';
import 'user_search_state.dart';

class UserSearchNotifier extends StateNotifier<UserSearchState> {
  final ChatService _chatService;
  final String? _token;
  Timer? _debounce;

  UserSearchNotifier(this._chatService, this._token) : super(const UserSearchInitial());

  void searchUsers(String query) {
    if (query.isEmpty) {
      state = const UserSearchInitial();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const UserSearchLoading();
      try {
        final users = await _chatService.searchUsers(query, token: _token);
        state = UserSearchSuccess(users);
      } catch (e) {
        state = UserSearchError(e.toString());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
