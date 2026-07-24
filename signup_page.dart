import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'api_config.dart';
import 'translated_text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;




  Future<void> insertRecord() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}signup.php"),
        body: {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "confirm_password": confirmPasswordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        _showSnack(data["message"] ?? "Account created successfully!");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      } else {
        _showSnack(data["message"] ?? "Error occurred");
      }
    } catch (e) {
      _showSnack("Server Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: TText(msg)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
        title: const TText("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.app_registration, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const TText(
              "Create Your Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            _field(nameController, "Full Name", Icons.person),
            _field(emailController, "Email", Icons.email),
            _field(passwordController, "Password", Icons.lock, true),
            _field(confirmPasswordController, "Confirm Password", Icons.lock_outline, true),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : insertRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const TText(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _field(TextEditingController controller, String hint, IconData icon, [bool isPassword = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: FutureBuilder<String>(

        future: TranslationService.translate(hint),
        builder: (context, snapshot) {
          return TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: snapshot.data ?? hint,
              prefixIcon: Icon(icon, color: Colors.green[700]),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}