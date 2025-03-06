import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/additional_info_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/customer_home.dart';
import 'screens/driver_home.dart';
import 'screens/admin_home.dart';
import 'firebase_options.dart'; // Ensure this exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boda Boda App',
      home: const AuthWrapper(), // ✅ Check user session here
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/additional_info': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return AdditionalInfoScreen(user: user);
        },
      },
    );
  }
}

// ✅ Automatically redirect user based on session
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        String role = userDoc.get("role");

        if (!mounted) return; // Prevents calling setState if widget is disposed

        if (role == "customer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHome()),
          );
        } else if (role == "driver") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverHome()),
          );
        } else if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHome()),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ), // Loading screen while checking session
    );
  }
}
