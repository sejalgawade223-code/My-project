import 'package:flutter/material.dart';
import 'session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final contactCtrl = TextEditingController();

  int? userId;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    userId = await SessionManager.getUserId();
    nameCtrl.text = await SessionManager.getName() ?? '';
    addressCtrl.text = await SessionManager.getAddress() ?? '';
    contactCtrl.text = await SessionManager.getContactNo() ?? '';
    setState(() {});
  }

  Future<void> saveProfile() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TText("User not logged in")),
      );
      return;
    }

    final email = await SessionManager.getEmail() ?? '';
    final role = await SessionManager.getRole() ?? 'customer';

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}update_profile.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "u_id": userId,
          "name": nameCtrl.text.trim(),
          "address": addressCtrl.text.trim(),
          "contact_no": contactCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        await SessionManager.saveSession(
          userId: userId!,
          email: email,
          name: nameCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          contactNo: contactCtrl.text.trim(),
          role: role,
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: TText("Profile update failed")),
          );
        }
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TText("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: ValueListenableBuilder(
        valueListenable: UserSession.languageNotifier,
        builder: (context, lang, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),

                _buildField(nameCtrl, "Full Name", Icons.person),
                const SizedBox(height: 15),

                _buildField(addressCtrl, "Address", Icons.location_on),
                const SizedBox(height: 15),

                _buildField(contactCtrl, "Contact Number", Icons.phone, keyboard: TextInputType.phone),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: saveProfile,
                    child: const TText("Save Changes", style: TextStyle(color: Colors.white)), // ✅ Translated
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return FutureBuilder<String>(
      future: UserSession.language == 'en'
          ? Future.value(label)
          : http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(label)}"))
          .then((res) => jsonDecode(res.body)[0][0][0].toString()),
      builder: (context, snapshot) {
        return TextField(
          controller: ctrl,
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: snapshot.data ?? label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}