import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../user_model/user_model.dart';
import 'advocate_chat_detail_screen.dart';
import 'chat_services.dart';

class AdvocateChatList extends StatefulWidget {
  @override
  _AdvocateChatListState createState() => _AdvocateChatListState();
}

class _AdvocateChatListState extends State<AdvocateChatList> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<UserModel?> _fetchUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromJson({
        'uid': doc.id,
        'username': doc['username'] ?? 'Unknown User',
        'email': doc['email'] ?? '',
        'role': doc['role'] ?? 'user',
      });
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  String _getDisplayName(UserModel user) {
    final rolePrefix = user.role == 'advocate' ? 'Adv ' : '';
    return '$rolePrefix${user.username ?? 'Unknown User'}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel?>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);
    final blue900 = Colors.blue[900];

    if (currentUser?.uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2, // Matches number of tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: blue900,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Chats" text on left
                const Text('Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Search bar on right
                Container(
                  width: 180, // Reduced width
                  height: 36, // Reduced height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12),
                      prefixIcon: Icon(Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14, // Smaller font
            ),
            tabs: const [
              Tab(text: 'Chats'),
              Tab(text: 'Calls'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildChatList(currentUser!, chatService),
            _buildCallHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(UserModel currentUser, ChatService chatService) {
    return StreamBuilder<List<String>>(
      stream: chatService.getChatRooms(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final chatRooms = snapshot.data ?? [];
        if (chatRooms.isEmpty) {
          return Center(child: Text('No conversations found',
              style: TextStyle(color: Colors.grey[600])));
        }
        return ListView.separated(
          padding: EdgeInsets.only(top: 16),
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final chatRoomId = chatRooms[index];
            final participants = _parseChatRoomId(chatRoomId, currentUser.uid);
            if (participants == null || participants.length != 2) {
              return _buildErrorTile('Invalid chat format');
            }
            return _buildChatListItem(context, participants, chatRoomId);
          },
        );
      },
    );
  }

  Widget _buildChatListItem(BuildContext context, List<String> participants, String chatRoomId) {
    final currentUserId = Provider.of<UserModel>(context).uid;
    final otherUserId = participants.firstWhere((id) => id != currentUserId);

    return FutureBuilder<UserModel?>(
      future: _fetchUser(otherUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingTile();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildRetryTile(() => _fetchUser(otherUserId));
        }
        final user = snapshot.data!;
        final displayName = _getDisplayName(user).toLowerCase();

        if (_searchQuery.isNotEmpty && !displayName.contains(_searchQuery)) {
          return SizedBox.shrink();
        }

        return _buildUserTile(context, user, chatRoomId);
      },
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user, String chatRoomId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .snapshots(),
      builder: (context, snapshot) {
        final lastMessage = snapshot.data?.get('lastMessage') ?? '';
        final timestamp = snapshot.data?.get('lastMessageTime') as Timestamp?;
        final timeText = timestamp != null
            ? DateFormat('hh:mm a').format(timestamp.toDate())
            : '';

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${user.uid}'),
          ),
          title: Text(
            _getDisplayName(user),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            lastMessage.isNotEmpty ? lastMessage : 'Start conversation',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Text(
            timeText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdvocateChatDetail(
                chatRoomId: chatRoomId,
                client: user,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
            size: 80,
            color: Colors.blue[200],
          ),
          SizedBox(height: 24),
          Text('No Call History',
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue[200],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text('Your call log will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<String>? _parseChatRoomId(String chatRoomId, String currentUserId) {
    try {
      final parts = chatRoomId.split('_');
      if (parts.length != 2) return null;
      if (!parts.contains(currentUserId)) return null;
      return parts;
    } catch (e) {
      return null;
    }
  }

  Widget _buildLoadingTile() => ListTile(
    title: LinearProgressIndicator(),
  );

  Widget _buildErrorTile(String message) => ListTile(
    title: Text(message, style: TextStyle(color: Colors.red)),
  );

  Widget _buildRetryTile(VoidCallback onRetry) => ListTile(
    title: Text('Tap to retry', style: TextStyle(color: Colors.orange)),
    onTap: onRetry,
  );
}
