import '../../models/conversation_model.dart';

abstract class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationModel> conversations;
  const ConversationsLoaded(this.conversations);
}

class ConversationsError extends ConversationsState {
  final String message;
  const ConversationsError(this.message);
}
