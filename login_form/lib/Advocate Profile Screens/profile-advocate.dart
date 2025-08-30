import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form/Advocate%20Profile%20Screens/join_as_lawyer.dart';
import 'package:login_form/auth_screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdvocateProfileSection extends StatelessWidget {
  const AdvocateProfileSection({super.key});

//profile picture upload and store

  // Logout functionality with confirmation dialog
  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // The dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and do not log out
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Perform logout
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to login screen or any other screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ); // Use your actual login screen route
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>> _fetchUserDetails() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return {
        'username': userDoc['username'] ?? 'Username not found',
        'email': userDoc['email'] ?? 'Email not found',
      };
    }
    return {'username': 'Username not found', 'email': 'Email not found'};
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings, color: Colors.black), onPressed: () {}),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, String>>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else {
            final userDetails = snapshot.data ?? {};
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/profile.png')),
                            const SizedBox(height: 8),
                            Text(
                              '${userDetails['username']}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userDetails['email'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Profile Settings"),
                      _buildSmallContainer(
                        context,
                        icon: Icons.edit,
                        title: "Edit Profile Information",
                        onTap: () {},
                      ),
                      _buildSmallContainer(
                        context,
                        icon: Icons.account_balance_rounded,
                        title: "Join As Advocate",
                        trailing: const Text("click", style: TextStyle(color: Colors.blue)),
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdvocateRegistrationForm()),
                        ); },
                      ),
                      _buildSmallContainer(
                        context,
                        icon: Icons.language,
                        title: "Language",
                        trailing: const Text("English", style: TextStyle(color: Colors.grey)),
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Preferences"),
                      _buildSmallContainer(
                        context,
                        icon: Icons.lock,
                        title: "Security",
                        onTap: () {},
                      ),
                      _buildSmallContainer(
                        context,
                        icon: Icons.color_lens,
                        title: "Billing and Invoices",
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Support"),
                      _buildSmallContainer(
                        context,
                        icon: Icons.help_outline,
                        title: "FAQs",
                        onTap: () {},
                      ),
                      _buildSmallContainer(
                        context,
                        icon: Icons.phone,
                        title: "Contact us", onTap: () {},
                      ),
                      _buildSmallContainer(context, icon: Icons.privacy_tip_outlined, title: "Log out", onTap: () => _logout(context)),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSmallContainer(BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
