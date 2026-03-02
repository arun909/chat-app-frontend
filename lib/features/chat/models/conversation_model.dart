import '../../auth/domain/entities/user_entity.dart';
import 'message_model.dart';

class ConversationModel {
  final String id;
  final List<UserEntity> participants;
  final MessageModel? lastMessage;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.updatedAt,
  });
//factory constructor in Dart allows us to control object creation. Unlike normal constructors, it can contain logic, validation, and even return existing instances or subclasses. It is commonly used in JSON parsing and design patterns like Singleton
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'] as List? ?? [];
    final participants = participantsRaw.map((p) {
      if (p is Map) {
        return UserEntity(
          id: p['_id']?.toString() ?? p['id']?.toString() ?? '',
          username:
              p['username']?.toString() ?? p['name']?.toString() ?? 'Unknown',
          email: p['email']?.toString() ?? '',
          token: '',
          profilePic: p['profilePic']?.toString(),
        );
      }
      return UserEntity(
          id: p.toString(), username: 'Unknown', email: '', token: '');
    }).toList();

    final lastMessageRaw = json['lastMessage'];
    final MessageModel? lastMessage = (lastMessageRaw is Map)
        ? MessageModel.fromJson(Map<String, dynamic>.from(lastMessageRaw))
        : null;

    return ConversationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      participants: participants,
      lastMessage: lastMessage,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// Helper to get the other participant's name (assuming 1-on-1 chat)
  String getOtherParticipantName(String currentUserId) {
    if (participants.isEmpty) return 'Unknown';
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => participants.first,
    );
    return other.username;
  }
}
