import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/validation.dart';
import '../services/auth_verification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthVerificationService _authVerificationService =
      AuthVerificationService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _leaderController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  String _selectedRole = "customer";
  late AnimationController _animationController;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> validateAdminCode(String enteredCode) async {
    DocumentSnapshot configDoc =
        await FirebaseFirestore.instance.collection("config").doc("settings").get();

    if (!configDoc.exists) {
      print("Admin settings document does not exist in Firestore!");
      return false;
    }

    String correctAdminCode = configDoc.get("admin_code");

    if (enteredCode == correctAdminCode) {
      return true;
    }

    return false;
  }

  void registerAdmin() async {
    String enteredCode = _adminCodeController.text.trim();

    bool isValid = await validateAdminCode(enteredCode);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid admin code!")));
      return;
    }

    register();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String phone = _phoneController.text.trim();
    String nationalId = _idController.text.trim();
    String station = _stationController.text.trim();
    String leader = _leaderController.text.trim();
    String adminCode = _adminCodeController.text.trim();

    try {
      if (_selectedRole == "admin") {
        bool isValidAdminCode = await validateAdminCode(adminCode);
        if (!isValidAdminCode) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid admin code!")));
          return;
        }
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        Map<String, dynamic> userData = {
          "name": name,
          "email": email,
          "phone": phone,
          "role": _selectedRole,
        };

        if (_selectedRole == "driver") {
          userData["national_id"] = nationalId;
          userData["station"] = station;
          if (leader.isNotEmpty) {
            userData["group_leader"] = leader;
          }
        }

        if (_selectedRole == "admin") {
          userData["admin_code"] = adminCode;
        }

        await _firestore.collection("users").doc(user.uid).set(userData);

        await _authVerificationService.sendEmailVerification();
        await _authVerificationService.verifyPhoneNumber(context, phone);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Please verify your email. Check your inbox and click the link before logging in."),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login'); // Go back to login
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validation.validateEmailPhoneNida(email: value),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                         return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    initialValue: "+255",
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validation.validateEmailPhoneNida(phone: value),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                    items: const ["customer", "driver", "admin"].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedRole == "driver") ...[
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: "National ID / License",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          Validation.validateEmailPhoneNida(nida: value),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _stationController,
                      decoration: const InputDecoration(
                        labelText: "Station (Kijiwe)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _leaderController,
                      decoration: const InputDecoration(
                        labelText: "Group Leader (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (_selectedRole == "admin") ...[
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: "National ID",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          Validation.validateEmailPhoneNida(nida: value),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _adminCodeController,
                      decoration: const InputDecoration(
                        labelText: "Admin Verification Code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _selectedRole == "admin" ? registerAdmin : register,
                    child: const Text("Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}