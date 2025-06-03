import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_bite/screens/landing/landing_screen.dart';
import 'package:home_bite/screens/sign_in/signin_screen.dart';
import 'package:home_bite/screens/sign_up/signup_screen.dart';
import 'package:home_bite/services/auth_gate.dart';

import 'firebase_options.dart';
import 'screens/home/main_navigation_screen.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with a shorter timeout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        // If Firebase takes too long, continue anyway
        print('Firebase initialization timed out, continuing with app startup');
        return Firebase.app();
      },
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue with app startup even if Firebase fails
  }

  // Run the app immediately
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      title: 'Home Bite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
        '/landing': (context) => const LandingScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const SignInScreen(),
      },
    );
  }
}
