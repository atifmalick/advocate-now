import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdvocateHomeScreen extends StatefulWidget {
  const AdvocateHomeScreen({super.key});

  @override
  State<AdvocateHomeScreen> createState() => _AdvocateHomeScreenState();
}

class _AdvocateHomeScreenState extends State<AdvocateHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Color primaryColor = Colors.blue[900]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('LegalMate', style: TextStyle(color: Colors.black),),
        elevation: 0,

      ),
      body: Column(
        children: [
          _PostInputField(primaryColor: primaryColor),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading posts'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return PostWidget(
                      postData: data,
                      postId: document.id,
                      primaryColor: primaryColor,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostInputField extends StatelessWidget {
  final Color primaryColor;
  const _PostInputField({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewPostScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: primaryColor),
            const SizedBox(width: 15),
            Text('Share your case insights...',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPosting = false;
  final Color primaryColor = Colors.blue[900]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _savePost,
            child: _isPosting
                ? CircularProgressIndicator(color: Colors.white)
                : Text('POST', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Write your legal insights here...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          autofocus: true,
          style: TextStyle(color: Colors.blue[900], fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await _firestore.collection('posts').add({
        'authorName': userData['username'] ?? 'anonymous',
        'authorTitle': userData['title'] ?? 'Legal Professional',
        'authorId': user.uid,
        'content': _contentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;
  final Color primaryColor;

  const PostWidget({
    super.key,
    required this.postData,
    required this.postId,
    required this.primaryColor,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isExpanded = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleLike() async {
    try {
      await _firestore.collection('posts').doc(widget.postId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          postId: widget.postId,
          primaryColor: widget.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.postData['timestamp'] as Timestamp;
    final dateTime = timestamp.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue[50]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: widget.primaryColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postData['authorName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.primaryColor,
                      ),
                    ),
                    Text(
                      '${widget.postData['authorTitle']} • ${timeago.format(dateTime)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.postData['content'],
              style: TextStyle(color: Colors.grey[800], height: 1.4),
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            if (widget.postData['content'].length > 100)
              TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? 'Show less' : 'Show more',
                  style: TextStyle(color: widget.primaryColor),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: widget.primaryColor),
                  onPressed: _handleLike,
                ),
                Text(
                  '${widget.postData['likesCount'] ?? 0}',
                  style: TextStyle(color: widget.primaryColor),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.comment_rounded, color: widget.primaryColor),
                  onPressed: _navigateToComments,
                ),
                Text(
                  '${widget.postData['commentsCount'] ?? 0}',
                  style: TextStyle(color: widget.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsScreen extends StatefulWidget {
  final String postId;
  final Color primaryColor;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.primaryColor,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await _firestore.collection('comments').add({
        'postId': widget.postId,
        'authorName': userData['name'] ?? 'Anonymous',
        'authorId': user.uid,
        'content': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update comments count in post document
      await _firestore.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding comment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: widget.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('comments')
                  .where('postId', isEqualTo: widget.postId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var comment = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return CommentTile(
                        comment: comment, primaryColor: widget.primaryColor);
                  },
                );
              },
            ),
          ),
          _CommentInputField(
            controller: _commentController,
            onSend: _addComment,
            primaryColor: widget.primaryColor,
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final Color primaryColor;

  const CommentTile({
    super.key,
    required this.comment,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = comment['timestamp'] as Timestamp;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Text(
                comment['authorName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeago.format(timestamp.toDate()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment['content'],
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color primaryColor;

  const _CommentInputField({
    required this.controller,
    required this.onSend,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blue[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
