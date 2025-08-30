import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_form/client%20screen/appointment_notification_client.dart';
import 'package:login_form/client%20screen/client-profile-tab.dart';
import 'package:login_form/client%20screen/home-screen-client.dart';

import 'detail_screen_advocate_clientHome.dart';

final String clientId = FirebaseAuth.instance.currentUser!.uid;

class Category {
  final IconData icon;
  final String title;
  Category(this.icon, this.title);
}

final List<Category> categories = [
  Category(Icons.family_restroom, 'Family Law'),
  Category(Icons.business_center, 'Corporate Law'),
  Category(Icons.monetization_on_rounded, 'Tax Law'),
  Category(Icons.gavel, 'Criminal Law'),
  Category(Icons.account_balance, 'Government Law'),
  Category(Icons.health_and_safety, 'Health Law'),
  Category(Icons.school, 'Education Law'),
  Category(Icons.home, 'Property Law'),
  Category(Icons.people, 'Civil Rights Law'),
  Category(Icons.public, 'International Law'),
  Category(Icons.policy, 'Constitutional Law'),
  Category(Icons.business, 'Commercial Law'),
  Category(Icons.account_box, 'Immigration Law'),
  Category(Icons.eco, 'Environmental Law'),
  Category(Icons.handshake, 'Labor & Employment Law'),
  Category(Icons.commute, 'Transport Law'),
  Category(Icons.emoji_people, 'Human Rights Law'),
  Category(Icons.child_care, 'Juvenile Law'),
  Category(Icons.security, 'Cyber & IT Law'),
  Category(Icons.warning, 'Tort Law'),
  Category(Icons.group, 'Consumer Protection Law'),
  Category(Icons.money, 'Banking & Finance Law'),
];


class LandingPageClient extends StatefulWidget {
  const LandingPageClient({Key? key}) : super(key: key);

  @override
  State<LandingPageClient> createState() => _LandingPageClientState();
}

class _LandingPageClientState extends State<LandingPageClient> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<Map<String, String>> fetchUserName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return {
        'username': userDoc['username'] ?? 'Username not found',
      };
    }
    return {'username': 'Username not found'};
  }

  Widget _CategoryCard(IconData icon, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 5;

    return SizedBox(
      width: cardWidth,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade900,
            child: FutureBuilder<Map<String, String>>(
              future: fetchUserName(),
              builder: (context, snapshot) {
                final name = snapshot.data?['username'] ?? 'Guest';
                final initials = name.isNotEmpty
                    ? name.split(' ').map((e) => e[0]).take(2).join()
                    : '??';
                return Text(
                  initials,
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            FutureBuilder<Map<String, String>>(
              future: fetchUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                    snapshot.data?['username'] ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                }
                return const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientNotificationsScreen()),
              );            },
            icon: Icon(Icons.notifications, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientProfileSection()),
              );
            },
            icon: Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,


      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Username and Icon
              const SizedBox(height: 2),

              // Main Advocate Banner
              SizedBox(
                width: 325,
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('images/home.png', fit: BoxFit.cover,),),),
              const SizedBox(height: 20),

              // Categories Section - Added Here
              Row(
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdvocateProfileScreen()),
                      );

                    },
                    child: const Text(
                      "See All >",
                    )
                  ),

                ],

              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 15),
                  itemBuilder: (context, index) => _CategoryCard(
                    categories[index].icon,
                    categories[index].title,
                  ),
                ),
              ),

              // Advocates List
              Row(
                children: [
                  const Text('Popular Advocates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdvocateProfileScreen()),
                        );
                      },
                      child: const Text(
                        "See All >",
                      )
                  ),
                ],
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdvocateProfileScreen()),
                  );
                },

                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('join_as_lawyer').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No Advocates found'));
                    }

                    final advocates = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: advocates.length,
                      itemBuilder: (context, index) {
                        final data = advocates[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 9),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage('images/blank_profile.png'),
                            ),
                            title: Text(data['fullName'] ?? 'No fullName'),
                            subtitle: Text('Experience: ${data['experience'] ?? 'N/A'} years'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('\Rs,${data['fees'] ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}