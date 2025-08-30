import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_form/user_model/user_model.dart';
import 'chat_services.dart';
import 'message_bubble.dart';

class AdvocateChatDetail extends StatefulWidget {
  final String chatRoomId;
  final UserModel client;

  const AdvocateChatDetail({
    required this.chatRoomId,
    required this.client,
  });

  @override
  _AdvocateChatDetailState createState() => _AdvocateChatDetailState();
}

class _AdvocateChatDetailState extends State<AdvocateChatDetail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<Message>> _messagesStream;

  @override
  void initState() {
    super.initState();
    final chatService = Provider.of<ChatService>(context, listen: false);
    _messagesStream = chatService.getMessages(widget.chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel?>(context);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png')),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.client.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_bg.png'), // Add subtle chat pattern
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && messages.isNotEmpty) {
                      _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent
                      );

                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUser.uid;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        showTime: index == messages.length - 1 ||
                            messages[index + 1].senderId != message.senderId,
                      );
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(
              Provider.of<ChatService>(context),
              currentUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatService chatService, UserModel currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  final message = Message(
                    senderId: currentUser.uid,
                    receiverId: widget.client.uid,
                    content: _controller.text,
                    timestamp: DateTime.now(),
                    chatRoomId: widget.chatRoomId,
                    id: '',

                  );
                  await chatService.sendMessage(message);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}