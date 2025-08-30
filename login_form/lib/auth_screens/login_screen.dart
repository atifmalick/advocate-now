import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../advocate screens/advocate-dashboard.dart';
import '../client screen/client-dashboard.dart';
import 'signup-screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkUserLoggedIn() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final String userRole = userDoc['role'];
        if (userRole == 'advocate') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvocateDashboard()),
          );
        } else if (userRole == 'client') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientDashboard()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                child: const Padding(
                  padding: EdgeInsets.only(top: 5), // Adjusted padding for better spacing
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel,color: Colors.white, size: 60,),
                      SizedBox(height: 10),
                      Text("Legal Mate", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                      ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const Text('Log in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black,),),
                    const SizedBox(height: 20),
                    _buildTextField(Icons.email_outlined, "Email", false, emailController, _validateEmail),
                    const SizedBox(height: 20),
                    _buildTextField(Icons.lock_outline, "Password", true, passwordController, _validatePassword),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forget password?",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Log in", style: TextStyle(color: Colors.white,)),
                    ),

                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("New user? Create account", style: TextStyle(color: Colors.white,),
                    ),
                    )],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField(
      IconData icon,
      String hint,
      bool obscure,
      TextEditingController controller,
      String? Function(String?)? validator,
      ) {
    return SizedBox(
      height: 60, // Fixed height
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust padding
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: validator,
      ),
    );
  }


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    const emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(emailPattern).hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        final String userRole = userDoc['role'];
        if (userRole == 'advocate') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdvocateDashboard()),
          );
        } else if (userRole == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ClientDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown user role. Please contact support.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not found. Please complete profile creation.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'Login failed. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An unexpected error occurred: $e')));
    } finally {
      setState(() => _isLoading = false);
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
