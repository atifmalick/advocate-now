import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../user_model/user_model.dart';
import '../client_side_chat/advocate_chat_detail_screen.dart';
import '../client_side_chat/chat_list_tile.dart';
import '../client_side_chat/chat_services.dart';

class ClientChatList extends StatefulWidget {
  const ClientChatList({super.key});

  @override
  State<ClientChatList> createState() => _ClientChatListState();
}

class _ClientChatListState extends State<ClientChatList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<UserModel?> _fetchClient(String clientId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(clientId).get();
      return UserModel.fromJson({
        'uid': doc.id,
        'username': doc['username'] ?? 'Unknown Client',
        'email': doc['email'] ?? '',
        'role': doc['role'] ?? 'client',
      });
    } catch (e) {
      print('Error fetching client: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel?>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Chats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 180,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 12),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<String>>(
        stream: chatService.getChatRooms(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return const Center(child: Text('No conversations yet!'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoomId = chatRooms[index];
              final participants = _parseChatRoomId(chatRoomId, currentUser.uid);

              if (participants == null) {
                return _buildErrorTile('Invalid chat format');
              }

              return _buildChatListItem(context, participants, chatRoomId);
            },
          );
        },
      ),
    );
  }

  List<String>? _parseChatRoomId(String chatRoomId, String currentUserId) {
    try {
      final parts = chatRoomId.split('_');
      if (parts.length != 2 || !parts.contains(currentUserId) || parts[0] == parts[1]) {
        return null;
      }
      return parts;
    } catch (e) {
      return null;
    }
  }

  Widget _buildChatListItem(BuildContext context, List<String> participants, String chatRoomId) {
    final currentUserId = Provider.of<UserModel>(context, listen: false).uid;
    final clientId = participants.firstWhere((id) => id != currentUserId);

    return FutureBuilder<UserModel?>(
      future: _fetchClient(clientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingTile();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildRetryTile(() => _fetchClient(clientId));
        }

        final client = snapshot.data!;
        if (_searchQuery.isNotEmpty && !client.username.toLowerCase().contains(_searchQuery)) {
          return const SizedBox.shrink(); // Hide non-matching results
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .doc(chatRoomId)
              .snapshots(),
          builder: (context, roomSnapshot) {
            final lastMessage = roomSnapshot.data?.get('lastMessage') ?? '';
            final timestamp = roomSnapshot.data?.get('lastMessageTime') as Timestamp?;

            return ChatListTile(
              otherUser: client,
              lastMessage: lastMessage,
              lastMessageTime: timestamp?.toDate(),
              unreadCount: 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdvocateChatDetail(
                    chatRoomId: chatRoomId,
                    client: client,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingTile() => const ListTile(
    title: Text('Loading...', style: TextStyle(color: Colors.grey)),
  );

  Widget _buildErrorTile(String message) => ListTile(
    title: Text(message, style: const TextStyle(color: Colors.red)),
    subtitle: const Text('Please try again later'),
  );

  Widget _buildRetryTile(VoidCallback onRetry) => ListTile(
    title: const Text('Unable to load', style: TextStyle(color: Colors.orange)),
    subtitle: const Text('Tap to retry'),
    onTap: onRetry,
  );
}
