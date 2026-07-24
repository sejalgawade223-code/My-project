import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _isLoading = false;


  Future<String> _translateHint(String hint) async {
    if (UserSession.language == 'en') return hint;
    final url = Uri.parse(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(hint)}");
    final res = await http.get(url);
    return jsonDecode(res.body)[0][0][0].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const TText("Set New Password", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TText("Create a strong password to protect your account.",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            // New Password Field
            _buildPasswordField(passwordController, "New Password"),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildPasswordField(confirmController, "Confirm Password"),
            const SizedBox(height: 32),

            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const TText("Reset Password", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return FutureBuilder<String>(
      future: _translateHint(hint),
      builder: (context, snapshot) {
        return TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: snapshot.data ?? hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
        );
      },
    );
  }



  Future<void> _handleResetPassword() async {
    if (passwordController.text.isEmpty || confirmController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmController.text) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}reset_password.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "password": passwordController.text,
          "confirm_password": confirmController.text,
        }),
      ).timeout(const Duration(seconds: 10));


      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        _showSnack(data["message"]);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnack(data["message"]);
      }
    } catch (e) {
      print("Error: $e");
      _showSnack("Server connection failed. Check Network.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TText(msg)));
  }
}
