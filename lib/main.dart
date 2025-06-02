import 'package:flutter/material.dart';
import 'package:home_bite/screens/home/home-screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:home_bite/screens/landing/landing_screen.dart';
import 'package:home_bite/screens/sign_in/signin_screen.dart';
import 'package:home_bite/screens/sign_up/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingScreen(),
      title: 'Home Bite',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/landing': (context) => LandingScreen(),
        '/signup': (context) => SignupScreen(),
        '/signin': (context) => SignInScreen(),
      },
    );
  }
}



