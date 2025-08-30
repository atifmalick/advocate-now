import 'package:flutter/material.dart';
import 'package:login_form/advocate%20screens/appointment_notification_advocate_screen.dart';
import 'package:login_form/chat_application/advocate%20side%20chat/client_chat_list.dart';
import '../Advocate Profile Screens/profile-advocate.dart';
import 'home_screen_advocate.dart';

class AdvocateDashboard extends StatefulWidget {
  const AdvocateDashboard({super.key});

  @override
  _AdvocateDashboardState createState() => _AdvocateDashboardState();
}


class _AdvocateDashboardState extends State<AdvocateDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdvocateHomeScreen(),
    const ClientChatList(),
    const AppointmentsScreen(),
    const AdvocateProfileSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: _screens[_selectedIndex]),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Your FAB logic here
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.people, 'Chat', 1),
                const SizedBox(width: 37), // For FAB spacing
                _buildNavItem(Icons.calendar_today, 'Appointments', 2),
                _buildNavItem(Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sample Screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home Screen'));
  }
}



class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Clients Screen'));
  }
}

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  AdvocateAppointmentsScreen();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvocateProfileSection();
  }
}
