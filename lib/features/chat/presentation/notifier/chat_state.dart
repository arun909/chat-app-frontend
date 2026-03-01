import '../../models/message_model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatSuccess extends ChatState {
  final List<MessageModel> messages;
  final bool isSending;

  const ChatSuccess({
    required this.messages,
    this.isSending = false,
  });

  ChatSuccess copyWith({
    List<MessageModel>? messages,
    bool? isSending,
  }) {
    return ChatSuccess(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}
