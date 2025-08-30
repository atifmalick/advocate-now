import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user_model/user_model.dart';
import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  String selectedRole = 'advocate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: 230,
                color: Colors.blue[900],
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel, color: Colors.white, size: 60),
                    SizedBox(height: 10),
                    Text("Legal Mate", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 220),
                  _buildTextField('Username', Icons.person, false, usernameController),
                  const SizedBox(height: 20),
                  _buildTextField('Email', Icons.email_outlined, false, emailController),
                  const SizedBox(height: 20),
                  _buildTextField('Password', Icons.lock, true, passwordController),
                  const SizedBox(height: 20),
                  _buildTextField('Confirm Password', Icons.lock, true, confirmPasswordController),
                  const SizedBox(height: 20),
                  _buildRoleDropdown(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await signUp(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.black54)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue,)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, bool obscureText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.person),
        ),
        onChanged: (String? newValue) {
          setState(() {
            selectedRole = newValue!;
          });
        },
        items: ['advocate', 'client'].map((role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(role),
          );
        }).toList(),
      ),
    );
  }

  Future<void> signUp(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User user = userCredential.user!;
      await user.sendEmailVerification();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent. Please verify your email before logging in.')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));

      _auth.userChanges().listen((updatedUser) async {
        if (updatedUser != null && updatedUser.emailVerified) {
          UserModel userModel = UserModel(
            uid: user.uid,
            email: emailController.text,
            role: selectedRole,
            username: usernameController.text,
          );
          await _firestore.collection('users').doc(userModel.uid).set(userModel.toJson());
        }
      });
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $error')),
      );
    }
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
