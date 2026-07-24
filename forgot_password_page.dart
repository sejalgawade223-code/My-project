import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp.dart';
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final TextEditingController emailController = TextEditingController();

  Future<void> sendOtp(BuildContext context) async {
    final url = Uri.parse("${ApiConfig.baseUrl}forgot_password.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TText("OTP sent successfully")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPPage(email: emailController.text.trim()),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TText(data["message"] ?? "Error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TText("Server error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const TText(
                "Forgot Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              const TText(
                "Enter your registered email to receive an OTP for password reset.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF388E3C)),
              ),
              const SizedBox(height: 40),


              _buildTranslatedField(emailController, "Email"),

              const SizedBox(height: 24),


              ElevatedButton(
                onPressed: () => sendOtp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const TText(
                  "Send OTP",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const TText(
                  "Back to Login",
                  style: TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTranslatedField(TextEditingController ctrl, String hint) {
    return FutureBuilder<String>(
      future: UserSession.language == 'en'
          ? Future.value(hint)
          : http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(hint)}"))
          .then((res) => jsonDecode(res.body)[0][0][0].toString()),
      builder: (context, snapshot) {
        return TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: snapshot.data ?? hint,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.green),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
