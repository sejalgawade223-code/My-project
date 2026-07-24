import 'package:flutter/material.dart';
import 'session_manager.dart';
import 'edit_profile.dart';
import 'user_session.dart';
import 'translated_text.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String address = '';
  String contactNo = '';

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    name = await SessionManager.getName() ?? '';
    email = await SessionManager.getEmail() ?? '';
    address = await SessionManager.getAddress() ?? '';
    contactNo = await SessionManager.getContactNo() ?? '';
    if (mounted) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: UserSession.languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7F2),
          appBar: AppBar(
            title: const TText("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green[700],
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.person, color: Colors.green[800], size: 50),
                ),
                const SizedBox(height: 15),
                Text(
                  name.isNotEmpty ? name : "User Name",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 30),


                _buildInfoCard(
                  icon: Icons.location_on,
                  content: address.isNotEmpty ? address : "No address added",
                  isTranslated: address.isEmpty,
                ),

                const SizedBox(height: 15),


                _buildInfoCard(
                  icon: Icons.call,
                  content: contactNo.isNotEmpty ? contactNo : "No contact added",
                  isTranslated: contactNo.isEmpty,
                ),

                const SizedBox(height: 30),


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const TText("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );

                      if (updated == true) {
                        loadProfileData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildInfoCard({required IconData icon, required String content, bool isTranslated = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 15),
          Expanded(
            child: isTranslated
                ? TText(content, style: const TextStyle(fontSize: 15))
                : Text(content, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}