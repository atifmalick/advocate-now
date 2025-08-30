import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String chatRoomId;
  final String id;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.chatRoomId,
    required  this.id,

  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'chatRoomId': chatRoomId,
      'id': id,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      chatRoomId: map['chatRoomId'],
      id: map['id']?.toString() ?? '',
    );
  }
}


class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTime;

  const MessageBubble({
    required this.message,
    required this.isMe,
    this.showTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0084FF) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
              child: Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),),
            ),
          ),
          if (showTime)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_formatTime(message.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12,),),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}