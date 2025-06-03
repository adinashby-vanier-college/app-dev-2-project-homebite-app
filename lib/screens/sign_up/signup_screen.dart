import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Top "Sign In" Link ───
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/signin');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Logo / Title ───
              const Text(
                'HomeBite',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // ─── Email ───
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Password ───
              TextField(
                controller: _passController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Confirm Password ───
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed:
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Sign Up Button ───
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E4743),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          setState(() => _isLoading = true);
                          try {
                            final email = _emailController.text.trim();
                            final pass = _passController.text;
                            final confirm = _confirmController.text;

                            if (email.isEmpty ||
                                pass.isEmpty ||
                                confirm.isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill out all registration fields',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (pass != confirm) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                ),
                              );
                              return;
                            }

                            // Use AuthService to sign up
                            await _authService.signUp(
                              email: email,
                              password: pass,
                            );

                            // Send email verification
                            await _authService.sendEmailVerification();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Account created successfully! Please check your email for verification.',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );

                            // Navigate to home page after successful signup
                            if (!mounted) return;
                            Navigator.of(context).pushReplacementNamed('/home');
                          } on FirebaseAuthException catch (e) {
                            String errorMessage = 'Sign-up failed';

                            if (e.code == 'weak-password') {
                              errorMessage = 'The password is too weak';
                            } else if (e.code == 'email-already-in-use') {
                              errorMessage = 'This email is already registered';
                            } else if (e.code == 'invalid-email') {
                              errorMessage = 'The email address is not valid';
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sign-up failed: ${e.toString()}',
                                ),
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Create Your Account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
              const SizedBox(height: 8),

              // ─── Terms of Use ───
              const Text(
                "By joining I agree to HomeBite's terms of use",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // ─── OR Divider ───
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or', style: TextStyle(color: Colors.black54)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Social Buttons ───
              OutlinedButton.icon(
                icon: const Icon(Icons.apple, size: 25),
                label: const Text('Continue with Apple'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // try {
                  //   final credential =
                  //       await SignInWithApple.getAppleIDCredential(
                  //         scopes: [
                  //           AppleIDAuthorizationScopes.email,
                  //           AppleIDAuthorizationScopes.fullName,
                  //         ],
                  //       );
                  //
                  //   // Handle the credential (e.g., send it to your backend for authentication)
                  //   print('User email: ${credential.email}');
                  //   print(
                  //     'User name: ${credential.givenName} ${credential.familyName}',
                  //   );
                  // } catch (error) {
                  //   print('Apple Sign-In failed: $error');
                  // }
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Image.asset('assets/images/icons/google.png', height: 15),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // try {
                  //   final GoogleSignIn googleSignIn = GoogleSignIn();
                  //   final GoogleSignInAccount? account = await googleSignIn.signIn();

                  //   if (account != null) {
                  //     print('User email: ${account.email}');
                  //     print('User name: ${account.displayName}');
                  //     // Handle the account (e.g., send it to your backend for authentication)
                  //   }
                  // } catch (error) {
                  //   print('Google Sign-In failed: $error');
                  // }
                },
              ),

              const SizedBox(height: 24),

              // ─── Bottom "Sign In" Prompt ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signin');
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
