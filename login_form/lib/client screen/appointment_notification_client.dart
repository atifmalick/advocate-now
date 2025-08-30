import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class ClientNotificationsScreen extends StatelessWidget {
  final String currentClientId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white70,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('clientId', isEqualTo: currentClientId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet.', style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String advocateName = data['advocateName'] ?? 'Unknown Advocate';
              String date = data['date'] ?? 'No date';
              String time = data['time'] ?? 'No time';
              Timestamp timestamp = data['timestamp'] ?? Timestamp.now();

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile/Icon Section
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[100],
                      ),
                      child: Icon(Icons.person, color: Colors.blue[700], size: 24),
                    ),
                    SizedBox(width: 12),

                    // Notification Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'You confirmed your appointment with Adv. $advocateName ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Time: $time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                          Text('Date: $date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                          Text(timeago.format(timestamp.toDate()), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),

                    // Chat Button
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {

                      },
                      child: Text('Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}