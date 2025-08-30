import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class AdvocateRegistrationForm extends StatefulWidget {
  const AdvocateRegistrationForm({super.key});

  @override
  _AdvocateRegistrationFormState createState() =>
      _AdvocateRegistrationFormState();
}

class _AdvocateRegistrationFormState extends State<AdvocateRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> selectedPracticeAreas = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Form fields
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  String licenseNumber = '';
  String gender = '';
  String availability = '';
  String city = '';
  String fees = '';
  String state = '';
  String experience = '';
  String education = '';
  String description = '';
  String courtAffiliation = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('join_as_lawyer')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          fullName = data['fullName'] ?? '';
          email = data['email'] ?? '';
          phoneNumber = data['phoneNumber'] ?? '';
          licenseNumber = data['licenseNumber'] ?? '';
          gender = data['gender'] ?? '';
          availability = data['availability'] ?? '';
          city = data['city'] ?? '';
          fees = data['fees'] ?? '';
          state = data['state'] ?? '';
          experience = data['experience'] ?? '';
          education = data['education'] ?? '';
          description = data['description'] ?? '';
          courtAffiliation = data['courtAffiliation'] ?? '';
          selectedPracticeAreas =
          List<String>.from(data['practiceAreas'] ?? []);
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User is not authenticated';

      String lawyerId = _firestore.collection('join_as_lawyer').doc().id;

      // Check if profile already exists
      DocumentSnapshot existingProfile = await _firestore
          .collection('join_as_lawyer')
          .doc(user.uid)
          .get();

      if (existingProfile.exists) {
        // If profile exists, update the profile
        await _firestore.collection('join_as_lawyer').doc(user.uid).update({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'licenseNumber': licenseNumber,
          'gender': gender,
          'availability': availability,
          'city': city,
          'fees': fees,
          'state': state,
          'experience': experience,
          'practiceAreas': selectedPracticeAreas,
          'description': description,
          'education': education,
          'courtAffiliation': courtAffiliation,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // If profile does not exist, create a new profile
        await _firestore.collection('join_as_lawyer').doc(user.uid).set({
          'lawyerId': lawyerId, // Add the unique lawyerId
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'licenseNumber': licenseNumber,
          'gender': gender,
          'availability': availability,
          'city': city,
          'fees': fees,
          'state': state,
          'experience': experience,
          'practiceAreas': selectedPracticeAreas,
          'description': description,
          'education': education,
          'courtAffiliation': courtAffiliation,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _showSuccessDialog();
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Form submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleError(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit form: $e')),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advocate Registration')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Full Name', (value) => fullName = value!),
              _buildTextField('Email', (value) => email = value!),
              _buildTextField('Phone Number', (value) => phoneNumber = value!),
              _buildTextField('License Number', (value) => licenseNumber = value!),
              _buildDropdownField('Gender', ['Male', 'Female', 'Other'], (value) => gender = value!),
              _buildDropdownField('Availability', ['Full-time', 'Part-time'], (value) => availability = value!),
              _buildTextField('City', (value) => city = value!),
              _buildTextField('Fees', (value) => fees = value!),
              _buildTextField('State', (value) => state = value!),
              _buildTextField('Experience', (value) => experience = value!),
              _buildMultiSelectField('Practice Areas', ['Criminal Law', 'Family Law', 'Corporate Law']),
              _buildTextField('Education', (value) => education = value!),
              _buildTextField('Court Affiliation', (value) => courtAffiliation = value!),
              _buildTextField('Description', (value) => description = value!),
              ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: DropdownButtonFormField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: MultiSelectDialogField(
        items: options.map((e) => MultiSelectItem(e, e)).toList(),
        title: Text(label),
        onConfirm: (values) => selectedPracticeAreas = values.cast<String>(),
      ),
    );
  }
}
