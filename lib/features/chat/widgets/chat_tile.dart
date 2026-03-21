import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';

class ChatTile extends StatelessWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherParticipant = conversation.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => conversation.participants.first,
    );
    final otherParticipantName =
        conversation.getOtherParticipantName(currentUserId);
    final lastMessage = conversation.lastMessage;
    final timeStr =
        _formatDateTime(lastMessage?.createdAt ?? conversation.updatedAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.darkSurface,
                  backgroundImage: otherParticipant.profilePic != null &&
                          otherParticipant.profilePic!.isNotEmpty
                      ? NetworkImage(
                          '${ApiConstants.serverUrl}${otherParticipant.profilePic}')
                      : null,
                  child: (otherParticipant.profilePic == null ||
                          otherParticipant.profilePic!.isEmpty)
                      ? Text(
                          otherParticipantName.isNotEmpty
                              ? otherParticipantName[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Online Status Dot (Mocked for now as requested UI has it)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.darkBackground, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherParticipantName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (lastMessage?.senderId == currentUserId) ...[
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppColors.tealAccent,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          lastMessage?.text ?? 'Started a conversation',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Mock Unread Badge if applicable (using image reference)
                      // In a real app, this would come from the conversation model
                      /*
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      */
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
