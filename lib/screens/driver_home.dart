import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Home")),
      drawer: const AppDrawer(), // 🛠 Add Sidebar Here
      body: const Center(child: Text("Welcome, Driver!")),
    );
  }
}
