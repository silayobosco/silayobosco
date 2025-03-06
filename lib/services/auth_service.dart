import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a User
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  // Login a User
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  // Logout a User
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}