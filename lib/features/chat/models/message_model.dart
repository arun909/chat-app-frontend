class MessageModel {
  final String id;
  final String senderId;
  final String conversationId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.conversationId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // sender may be a populated object or just an ID string
    String senderId = '';
    final senderRaw = json['sender'];
    if (senderRaw is Map) {
      senderId = senderRaw['_id']?.toString() ?? senderRaw['id']?.toString() ?? '';
    } else if (senderRaw is String) {
      senderId = senderRaw;
    }

    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: senderId,
      conversationId: json['conversation']?.toString() ?? '',
      text: json['text']?.toString() ?? json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
