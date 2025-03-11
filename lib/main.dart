import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'firebase_options.dart'; // Ensure this exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensures all plugins are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Ensure this exists
  ); // ✅ Properly initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boda Boda App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
