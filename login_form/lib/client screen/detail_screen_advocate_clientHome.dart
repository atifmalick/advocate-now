import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailedLawyerScreen extends StatefulWidget {
  final String lawyerId;

  DetailedLawyerScreen({required this.lawyerId});

  @override
  _DetailedLawyerScreenState createState() => _DetailedLawyerScreenState();
}
final User? currentUser = FirebaseAuth.instance.currentUser;
final String clientId = currentUser?.uid ?? '';

class _DetailedLawyerScreenState extends State<DetailedLawyerScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final advocateNameController = TextEditingController(); // New input field

  Future<DocumentSnapshot> fetchLawyerDetails() async {
    if (widget.lawyerId.isEmpty) {
      throw Exception('Invalid Lawyer ID');
    }

    return await FirebaseFirestore.instance
        .collection('join_as_lawyer')
        .doc(widget.lawyerId)
        .get();
  }

  Future<void> _bookAppointment() async {
    // Get current user with clearer variable name
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book an appointment')),
      );
      return;
    }

    // Validate form fields
    if (dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        phoneController.text.isEmpty ||
        nameController.text.isEmpty ||
        advocateNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Debug print to verify clientId
    print('Storing clientId: ${currentUser.uid}');
    print('Using lawyerId: ${widget.lawyerId}');

    final appointmentData = {
      'date': dateController.text,
      'time': timeController.text,
      'phone': phoneController.text,
      'name': nameController.text,
      'advocateName': advocateNameController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'lawyerId': widget.lawyerId,
      'clientId': currentUser.uid, // Directly use UID from authenticated user
    };

    try {
      // Explicit document reference with debug logging
      final docRef = await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      print('Appointment stored with ID: ${docRef.id}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Appointment booked successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Clear form after submission
      dateController.clear();
      timeController.clear();
      phoneController.clear();
      nameController.clear();
      advocateNameController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Booking'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchLawyerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Lawyer not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          data['profileImage'] ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['fullName'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(data['courtAffiliation'] ?? 'N/A'),
                            Text(
                              '${data['education'] ?? 'N/A'} | ${data['experience'] ?? 'N/A'} Yrs Experience',
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                // Contact
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        // Button action (e.g., open dialer)
                      },
                      child: Text(
                        data['phoneNumber'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(),
                // Appointment Details
                Container(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '2. Select Date & Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      dateController.text =
                                      "${pickedDate.toLocal()}".split(' ')[0];
                                    });
                                  }
                                },
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: dateController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Date',
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      timeController.text = pickedTime.format(context);
                                    });
                                  }
                                },
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: timeController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Time',
                                      prefixIcon: Icon(Icons.access_time),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            prefixText: '+92 ',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (!value.startsWith('+92')) {
                              return 'Phone number must start with +92';
                            }
                            if (value.length != 13) {
                              return 'Phone number must be 11 digits (excluding +92)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Client Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: advocateNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Advocate Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: _bookAppointment,
                              child: const Text(
                                'Book Appointment',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}