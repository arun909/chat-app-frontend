import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/notifier/login_state.dart';
import '../../services/chat_service.dart';
import '../notifier/user_search_notifier.dart';
import '../notifier/user_search_state.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatService(dio);
});

final userSearchNotifierProvider = StateNotifierProvider<UserSearchNotifier, UserSearchState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final loginState = ref.watch(loginNotifierProvider);
  String? token;
  if (loginState is LoginSuccess) {
    token = loginState.user.token;
  }
  return UserSearchNotifier(chatService, token);
});
