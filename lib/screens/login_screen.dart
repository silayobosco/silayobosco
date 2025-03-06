import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../screens/additional_info_screen.dart';
import '../screens/home_screen.dart';
import '../utils/validation.dart';
import '../ui/entry_field.dart';
import '../ui/button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ Email & Password Login
  void login() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null && mounted) {
        final role = await _getUserRole(user.uid);
        if (role != null) {
          navigateToHome(role);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
      }
    }
  }

  // ✅ Google Sign-In
  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null && mounted) {
        final role = await _getUserRole(user.uid);
        if (role != null) {
          navigateToHome(role);
        } else {
          navigateToAdditionalInfo(user);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "User role is missing please provide additional info",
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In Failed: $error")),
        );
      }
      print("Google Sign-In error: $error");
    }
  }

  // ✅ Navigate to Home
  void navigateToHome(String role) {
    if (!mounted) return;
    Future.microtask(() {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  // ✅ Fetch User Role
  Future<String?> _getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection("users").doc(uid).get();
      return userDoc.exists ? userDoc.get("role") : null;
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      return null;
    }
  }

  // ✅ Navigate to Additional Info
  void navigateToAdditionalInfo(User user) {
    if (mounted) {
      Future.microtask(() {
        if (mounted) {
          print("Navigating to /additional_info");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdditionalInfoScreen(user: user),
            ),
          );
        }
      });
    }
  }

  // ✅ Forgot Password Function
  void showResetPasswordDialog() {
    TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reset Password"),
            content: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Enter your email"),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  String email = emailController.text.trim();
                  if (email.isEmpty || !email.contains("@")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid email"),
                      ),
                    );
                    return;
                  }
                  try {
                    await _auth.sendPasswordResetEmail(email: email);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password reset email sent"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text("Send"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              ElevatedButton.icon(
                icon: Image.asset("assets/google_logo.png", height: 24),
                label: const Text("Sign in with Google"),
                onPressed: _handleSignIn,
              ),
              const Text(
                "Login to your account",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //✅ Email Field
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    EntryField(
                      hintText: "Email",
                      controller: _emailController,
                      validator:
                          (value) =>
                              Validation.validateEmailPhoneNida(email: value),
                    ),
                    //✅ Password Field
                    const SizedBox(height: 20),
                    EntryField(
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                    ),
                  ],
                ),
              ),
              //✅ Login Button
              const SizedBox(height: 20),
              Button(
                buttonColor: Colors.greenAccent[700],
                textColor: Colors.white,
                text: "Login",
                onTap: login,
              ),
              //✅ Register Button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text("Don't have an account? Register"),
              ),
              //✅ Forgot Password Button
              TextButton(
                onPressed: showResetPasswordDialog,
                child: const Text("Forgot Password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
