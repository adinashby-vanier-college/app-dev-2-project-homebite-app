import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_bite/screens/home/main_navigation_screen.dart';
import 'package:home_bite/screens/landing/landing_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is signed in, show MainNavigationScreen
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }
        // Otherwise, show LandingScreen
        return const LandingScreen();
      },
    );
  }
}
