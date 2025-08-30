import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form/chat_application/client_side_chat/advocate_chat_detail_screen.dart';
import 'package:login_form/user_model/user_model.dart';
import '../chat_application/client_side_chat/advocate_chat_list.dart';
import 'detail_screen_advocate_clientHome.dart';

class AdvocateProfileScreen extends StatefulWidget {
  const AdvocateProfileScreen({super.key});

  @override
  State<AdvocateProfileScreen> createState() => _AdvocateProfileScreenState();
}
final String clientId = FirebaseAuth.instance.currentUser!.uid;


class _AdvocateProfileScreenState extends State<AdvocateProfileScreen> {
  String selectedCity = '';
  String selectedPracticeArea = '';
  String courtAffiliation = '';
  List<String> availableCities = [];
  List<String> availablePracticeAreas = [];
  List<String> availablecourtAffiliation = [];
  final String clientId = FirebaseAuth.instance.currentUser!.uid;

  // Add this function to handle chat initiation
  Future<void> _startChat(BuildContext context, String advocateId, dynamic advocate) async {
    try {

      // Generate chat room ID
      final chatRoomId = _generateChatRoomId(advocateId:  advocate.uid, currentUserId: currentUser!.uid);

      // Check if chat room exists
      final chatRoomRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'participants': [clientId, advocateId],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      // Navigate to chat screen
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => AdvocateChatList(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: ${e.toString()}')),
      );
    }
  }
// Inside _AdvocateProfileScreenState class
  String _generateChatRoomId({
    required String currentUserId,
    required String advocateId,
  }) {
    List<String> ids = [currentUserId, advocateId];
    ids.sort(); // Alphabetical order to avoid duplicates
    return ids.join('_');
  }
  
  @override
  void initState() {
    super.initState();
    fetchFilters();
  }

  Future<void> fetchFilters() async {
    var snapshot = await FirebaseFirestore.instance.collection('join_as_lawyer').get();
    Set<String> cities = {};
    Set<String> courtAffiliation = {};
    Set<String> practiceAreas = {};

    for (var doc in snapshot.docs) {
      var data = doc.data();
      cities.add(data['city'] ?? 'Unknown');
      courtAffiliation.add(data['courtAffiliation'] ?? 'No Court');
      List<dynamic> areas = data['practiceAreas'] ?? [];
      practiceAreas.addAll(areas.map((e) => e.toString()));
    }

    setState(() {
      availableCities = cities.toList();
      availablecourtAffiliation = courtAffiliation.toList();
      availablePracticeAreas = practiceAreas.toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advocates", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white70,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Column(
            children: [
              // Filters Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey.shade100),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: selectedCity.isEmpty ? null : selectedCity,
                          decoration: const InputDecoration(
                            hintText: 'Enter City',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          icon: const SizedBox(),
                          items: availableCities
                              .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 45,
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey.shade100),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                value: selectedPracticeArea.isEmpty ? null : selectedPracticeArea,
                                decoration: const InputDecoration(
                                  hintText: 'Search by Fields',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                icon: const SizedBox(),
                                items: availablePracticeAreas
                                    .map((area) => DropdownMenuItem(
                                  value: area,
                                  child: Text(area),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPracticeArea = value ?? '';
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.search, color: Colors.blue.shade900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('join_as_lawyer').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching data"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No lawyers found"));
                    }

                    var lawyers = snapshot.data!.docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String city = data['city'] ?? '';
                      List<String> practiceAreas = List<String>.from(data['practiceAreas'] ?? []);
                      return (selectedCity.isEmpty || city == selectedCity) &&
                          (selectedPracticeArea.isEmpty || practiceAreas.contains(selectedPracticeArea));
                    }).toList();

                    if (lawyers.isEmpty) {
                      return const Center(child: Text("No lawyers match the filters"));
                    }

                    return ListView.builder(
                      itemCount: lawyers.length,
                      itemBuilder: (context, index) {
                        var lawyerData = lawyers[index].data() as Map<String, dynamic>;
                        String fullName = lawyerData['fullName'] ?? 'No Name';
                        List<String> practiceAreas = List<String>.from(lawyerData['practiceAreas'] ?? []);
                        String profilePictureUrl = lawyerData['profilePictureUrl'] ?? "";
                        String fees = lawyerData['fees'] ?? 'N/A';
                        String education = lawyerData['education'] ?? 'No Education Info';
                        String experience = lawyerData['experience'] ?? 'No Experience Info';
                        String court = lawyerData['courtAffiliation'] ?? 'No Experience Info';
                        String lawyerId = lawyers[index].id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: profilePictureUrl.isNotEmpty
                                          ? NetworkImage(profilePictureUrl)
                                          : null,
                                      backgroundColor: Colors.grey.shade300,
                                      child: profilePictureUrl.isEmpty
                                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Adv. $fullName",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            "PBC Verified",
                                            style: TextStyle(fontSize: 14, color: Colors.green),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            "$education | $court ",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      children: [
                                        Text("Reviews", style: TextStyle(fontSize: 14)),
                                        Text("4.5", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text("Experience", style: TextStyle(fontSize: 14)),
                                        Text("$experience yrs", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Column(
                                      children: [
                                        Text("Satisfaction", style: TextStyle(fontSize: 14)),
                                        Text("90%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: practiceAreas.isNotEmpty
                                        ? practiceAreas.map((area) => _buildChip(area)).toList()
                                        : [
                                      const Text(
                                        "No practice areas available",
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Video Consultation",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rs. $fees",
                                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          // Navigate to chat screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdvocateChatDetail(
                                                chatRoomId: _generateChatRoomId(
                                                  currentUserId: clientId,
                                                  advocateId: lawyerId,
                                                ),
                                                client: UserModel( // ✅ Create UserModel from lawyer data
                                                  uid: lawyerId,
                                                  username: fullName,
                                                  email: '', // Add if available
                                                  role: 'advocate',
                                                ), // Pass the advocate's UserModel
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Message",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailedLawyerScreen(
                                                lawyerId: lawyerId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "View Profile",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}
