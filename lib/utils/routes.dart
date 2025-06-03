// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:home_bite/screens/home/main_navigation_screen.dart';
import 'package:home_bite/screens/sign_up/signup_screen.dart';

import '../screens/landing/landing_screen.dart';
import '../screens/sign_in/signin_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/landing':
          (context) => const LandingScreen(), // Update with your landing page
      '/home': (context) => const MainNavigationScreen(),
      '/signup': (context) => const SignupScreen(),
      '/signin': (context) => const SignInScreen(), // Add other routes here
    };
  }
}
