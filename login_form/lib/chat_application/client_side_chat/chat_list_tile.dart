import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../user_model/user_model.dart';

class ChatListTile extends StatelessWidget {
  final UserModel otherUser;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatListTile({
    Key? key,
    required this.otherUser,
    required this.lastMessage,
    required this.onTap,
    this.lastMessageTime,
    this.unreadCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage('assets/profile.png')),
      title: Text(
        otherUser.username,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        lastMessage.isNotEmpty
            ? lastMessage
            : 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMessageTime != null)
            Text(
              DateFormat('HH:mm').format(lastMessageTime!),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}