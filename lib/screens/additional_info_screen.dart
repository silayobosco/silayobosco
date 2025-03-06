import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validation.dart';
import 'home_screen.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final User user;

  const AdditionalInfoScreen({super.key, required this.user});

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _leaderController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRole;

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void saveAdditionalInfo() async {
    if (_formKey.currentState!.validate()) {
      String phone = _phoneController.text.trim();
      String? nationalId = _idController.text.trim();
      String? station = _stationController.text.trim();
      String? leader = _leaderController.text.trim();
      String? adminCode = _adminCodeController.text.trim();
      String? password = _passwordController.text.trim();

      if (_selectedRole == null || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields")),
        );
        return;
      }

      if (_selectedRole == "Admin") {
        bool isValid = await validateAdminCode(adminCode!);
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid admin code!")));
          return;
        }
      }

      Map<String, dynamic> userData = {
        'role': _selectedRole,
        'phone': phone,
      };

      if (_selectedRole == "Driver") {
        userData["national_id"] = nationalId;
        userData["station"] = station;
        if (leader != null && leader.isNotEmpty) {
          userData["group_leader"] = leader;
        }
      }

      if (_selectedRole == "Admin") {
        userData["admin_code"] = adminCode;
      }

      if (password != null && password.isNotEmpty) {
        userData["password"] = password;
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.uid)
          .update(userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: const Text("Select Role"),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  items: const ["Customer", "Driver", "Admin"].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  initialValue: "+255",
                  decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      Validation.validateEmailPhoneNida(phone: value),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),                    
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
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
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                    if (value != null && value.isNotEmpty && value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                if (_selectedRole == "Driver") ...[
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
                if (_selectedRole == "Admin") ...[
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
                  onPressed: saveAdditionalInfo,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}