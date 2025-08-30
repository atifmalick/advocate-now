
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_bubble.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message) async {
    // Add message to messages collection
    await _firestore.collection('messages').add(message.toMap());

    // Update chat room with last message details
    await _firestore.collection('chat_rooms').doc(message.chatRoomId).set({
      'participants': [message.senderId, message.receiverId],
      'lastMessage': message.content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromMap(doc.data()))
        .toList());
  }

  Stream<List<String>> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
