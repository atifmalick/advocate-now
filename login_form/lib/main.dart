import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:login_form/user_model/user_model.dart';
import 'package:login_form/Advocate%20Profile%20Screens/profile-provider.dart';
import 'advocate screens/advocate-dashboard.dart';
import 'auth_screens/login_screen.dart';
import 'chat_application/client_side_chat/chat_services.dart';
import 'client screen/client-dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<UserModel?>(
          create: (context) => _userModelStream(),
          initialData: null,
        ),
        Provider<ChatService>(create: (_) => ChatService()),
        Provider(
          create: (context) => Profile(
            fullName: '',
            contactNumber: '',
            yearsOfExperience: '',
            location: '',
            bio: '',
            age: 0,
            gender: '',
            city: '',
            postcode: '',
            address: '',
            email: '',
            officeAddress: '',
            licenseNumber: '',
            barAssociation: '',
            specialization: '',
            education: '',
            languagesSpoken: '',
            courtAffiliations: '',
            notableCases: '',
            awards: '',
            workHours: '',
            consultationFee: 0.0,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Stream<UserModel?> _userModelStream() {
  return FirebaseAuth.instance.authStateChanges().asyncMap((firebaseUser) async {
    if (firebaseUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    return UserModel.fromJson({
      'uid': doc.id,
      'username': doc['username'],
      'email': doc['email'],
      'role': doc['role'],
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal Mate',
      builder: (context, child) => child!,
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<Widget> getNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role');

    if (isLoggedIn && role == 'client') {
      return const ClientDashboard();
    } else if (isLoggedIn && role == 'advocate') {
      return const AdvocateDashboard();
    } else {
      return const AuthenticationWrapper();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return FutureBuilder<Widget>(
      future: getNextScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedSplashScreen(
            duration: 2000,
            splash: SafeArea(
              child: SingleChildScrollView(  // Wrap the content with SingleChildScrollView
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/splash.jpg', width: 300, height: 250, fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    TyperAnimatedTextKit(text: ['Legal Mate'], textStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color:  Colors.blue[900],
                      ),
                      speed: const Duration(milliseconds: 100),
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 2000),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.white,
            nextScreen: snapshot.data!,
            splashIconSize: 400,
            splashTransition: SplashTransition.fadeTransition,
          );
        } else {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel?>(context);

    if (userModel == null) return const LoginScreen();

    return userModel.role == 'advocate'
        ? const AdvocateDashboard()
        : const ClientDashboard();
  }
}
