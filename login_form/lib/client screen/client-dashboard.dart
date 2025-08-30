import 'package:flutter/material.dart';
import 'package:login_form/chat_application/client_side_chat/advocate_chat_list.dart';
import 'package:login_form/client%20screen/client-profile-tab.dart';
import 'package:login_form/client%20screen/home-screen-client.dart';
import 'appointment_notification_client.dart';
import 'landing_page_client.dart';

void main() {
  runApp(const ClientDashboard());
}

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LandingPageClient(),
    AdvocateChatList(),
    const NotificationScreen(userId: ''),
    const ClientProfileSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: _screens[_currentIndex]),

      //+button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your FAB action here
        },
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.chat, 'Message', 1),
                const SizedBox(width: 37), // Space for FAB
                _buildNavItem(Icons.notifications, 'Appointments', 2),
                _buildNavItem(Icons.settings, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == _currentIndex;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.blue.shade900 : Colors.grey,
                size: isSelected ? 28 : 24),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                  color: isSelected ?Colors.blue.shade900 : Colors.grey,
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AdvocateProfileScreen()
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required String receiverId, required receiverName, required bool isAdvocate});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chat-Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClientNotificationsScreen(),
    );
  }
}


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const ClientProfileSection()
    );
  }
}
