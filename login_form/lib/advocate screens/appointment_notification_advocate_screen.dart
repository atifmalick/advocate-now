import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdvocateAppointmentsScreen extends StatelessWidget {
  final String currentLawyerId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments ", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white70,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('lawyerId', isEqualTo: currentLawyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var appointment = snapshot.data!.docs[index];
              return AppointmentCard(
                clientName: appointment['name'],
                date: appointment['date'],
                time: appointment['time'],
                phone: appointment['phone'],
                timestamp: appointment['timestamp'].toDate(),
              );
            },
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String clientName;
  final String date;
  final String time;
  final String phone;
  final DateTime timestamp;

  const AppointmentCard({
    required this.clientName,
    required this.date,
    required this.time,
    required this.phone,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
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
                        text: '$clientName ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'has booked an appointment with you.'),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text('Time: $time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700]),),
                Text('Date: $date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700]),),
                Text(timeago.format(timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[600]),),

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
              // Implement chat navigation
            },
            child: Text('Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );



  }
}