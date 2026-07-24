import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'setnewpassword.dart';
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class OTPPage extends StatefulWidget {
  final String email;
  const OTPPage({super.key, required this.email});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOtp() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}verify_otp.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": otpController.text.trim(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP Error ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordPage(email: widget.email),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TText(data["message"] ?? "Invalid OTP")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TText("Server error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const TText("Verify OTP"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TText(
                    "OTP Verification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const TText(
                    "Enter the OTP sent to",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  _buildTranslatedField(otpController, "Enter OTP"),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const TText(
                      "Verify OTP",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
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
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: snapshot.data ?? hint,
            prefixIcon: const Icon(Icons.lock_outline),
            filled: true,
            fillColor: Colors.green[50],
            counterText: "",
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
