import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'session_manager.dart';
import 'forgot_password_page.dart';
import 'cart_page.dart';
import 'signup_page.dart';
import 'order_detail_page.dart';
import 'home.dart';
import 'admin.dart';
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class LoginPage extends StatefulWidget {
  final Map<String, dynamic>? productToAdd;
  final bool redirectToCart;
  final bool redirectToOrder;

  const LoginPage({
    super.key,
    this.productToAdd,
    this.redirectToCart = false,
    this.redirectToOrder = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TText("Please fill all fields")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}login.php"),
        body: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final user = data['user'];
        final int userId = int.parse(user['id'].toString());
        final String role = user['role']?.toString().toLowerCase() ?? 'customer';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user['email'] ?? '');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', role);
        await prefs.setInt('userId', userId);

        await SessionManager.saveSession(
          userId: userId,
          email: user['email'] ?? '',
          name: user['name'] ?? '',
          address: user['address'] ?? '',
          contactNo: user['contact_no'] ?? '',
          role: role,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TText("Login Successful")),
        );


        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminPanelPage()), (route) => false);
        } else {
          if (widget.redirectToCart) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CartPage()), (route) => false);
          } else if (widget.redirectToOrder && widget.productToAdd != null) {
            final buyNowCart = [{
              "p_id": widget.productToAdd!['p_id'],
              "name": widget.productToAdd!['name'],
              "price": widget.productToAdd!['price'],
              "quantity": 1,
            }];
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailPage(
                  cartItems: buyNowCart,
                  totalAmount: double.parse(widget.productToAdd!['price'].toString())
              )),
                  (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Home()), (route) => false);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TText(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
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
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
            else Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Home()), (route) => false);
          },
        ),
        title: const TText("Login", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.eco, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("Fertismart", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 10),
              const TText("Login to continue", style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTranslatedField(emailController, "Email", Icons.email),
                      const SizedBox(height: 20),
                      _buildTranslatedField(passwordController, "Password", Icons.lock, obscure: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const TText("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                        child: const TText("Don't have an account? Sign Up", style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage())),
                        child: const TText("Forgot Password?", style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTranslatedField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false}) {
    return FutureBuilder<String>(
      future: UserSession.language == 'en'
          ? Future.value(hint)
          : http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(hint)}"))
          .then((res) => jsonDecode(res.body)[0][0][0].toString()),
      builder: (context, snapshot) {
        return TextField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: snapshot.data ?? hint,
            prefixIcon: Icon(icon, color: Colors.green),
            filled: true,
            fillColor: Colors.green[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        );
      },
    );
  }
}