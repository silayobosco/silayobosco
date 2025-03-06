import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_home.dart';
import 'driver_home.dart';
import 'admin_home.dart';
import 'additional_info_screen.dart'; // Import the additional info screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Redirect to Additional Info Screen if role is missing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdditionalInfoScreen(user: FirebaseAuth.instance.currentUser!),
              ),
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        String role = snapshot.data!;
        if (role == "Customer") return const CustomerHome();
        if (role == "Driver") return const DriverHome();
        if (role == "Admin") return const AdminHome();

        return const Center(child: Text("Invalid Role"));
      },
    );
  }

  Future<String?> getUserRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Check if the role exists in Firestore
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc['role'] as String?;
    }
    return null; // Return null if role is missing
  }
}
