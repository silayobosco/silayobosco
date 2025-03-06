import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Home")),
      drawer: const AppDrawer(), // 🛠 Add Sidebar Here
      body: const Center(child: Text("Welcome, Admin!")),
    );
  }
}
