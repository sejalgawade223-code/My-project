import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'translated_text.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List users = [];
  bool loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  Future<void> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}admin_get_users.php"));
      final decoded = jsonDecode(res.body);

      if (mounted) {
        setState(() {
          users = (decoded is List) ? decoded : [];
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const TText("Manage Users", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : users.isEmpty
          ? const Center(child: TText("No users found", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[50],
                  child: Icon(Icons.person, color: Colors.green[700], size: 30),
                ),
                title: Text(
                  u['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.email_outlined, "Email", u['email'] ?? ''),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.phone_android, "Phone", u['contact_no'] ?? ''),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.admin_panel_settings_outlined, "Role", u['role'] ?? 'User'),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                onTap: () {

                },
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.green[600]),
        const SizedBox(width: 6),
        TText("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        Expanded(
          child: TText(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
