import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Home")),
      drawer: const AppDrawer(), // 🛠 Add Sidebar Here
      body: const Center(child: Text("Welcome, Customer!")),
    );
  }
}
