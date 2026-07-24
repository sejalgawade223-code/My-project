// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'admin_product_list.dart';
// import 'admin_orders_page.dart';
// import 'admin_user_page.dart';
// import 'admin_payment_history.dart';
// import 'QuizListPage.dart';
// import 'admin_reviews_page.dart';
// import 'login.dart';
// import 'user_session.dart';
// import 'translated_text.dart';
//
// class AdminPanelPage extends StatefulWidget {
//   const AdminPanelPage({super.key});
//
//   @override
//   State<AdminPanelPage> createState() => _AdminPanelPageState();
// }
//
// class _AdminPanelPageState extends State<AdminPanelPage> {
//
//
//
//   void _nav(Widget page) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7F2),
//       appBar: AppBar(
//         title: const TText("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//         backgroundColor: Colors.green[700],
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.g_translate, color: Colors.white, size: 22),
//             onPressed: () => _showLanguageDialog(),
//           ),
//         ],
//       ),
//
//
//       drawer: Drawer(
//         child: Column(
//           children: [
//             UserAccountsDrawerHeader(
//               decoration: BoxDecoration(color: Colors.green[700]),
//               accountName: const TText("Administrator", style: TextStyle(fontWeight: FontWeight.bold)),
//               accountEmail: FutureBuilder<String?>(
//                 future: SharedPreferences.getInstance().then((prefs) => prefs.getString('userEmail')),
//                 builder: (context, snapshot) => Text(snapshot.data ?? "admin@smartfarm.com"),
//               ),
//               currentAccountPicture: const CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.green),
//               ),
//             ),
//             _drawerTile(Icons.shopping_bag_outlined, "Manage Fertilizers", const AdminProductListPage()),
//             _drawerTile(Icons.local_shipping_outlined, "View Orders", const AdminOrdersPage()),
//             _drawerTile(Icons.quiz_outlined, "Manage Quiz", const QuizListPage()),
//             _drawerTile(Icons.people_outline, "Manage Users", const AdminUsersPage()),
//             _drawerTile(Icons.account_balance_wallet_outlined, "Payment History", const AdminPaymentHistory()),
//             _drawerTile(Icons.reviews_outlined, "Product Reviews", const AdminReviewsPage()),
//             const Spacer(),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout_rounded, color: Colors.red),
//               title: const TText("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//               onTap: _handleLogout,
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//
//
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: GridView.count(
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           children: [
//             _menuCard(Icons.inventory_2, "Fertilizers", Colors.blue, const AdminProductListPage()),
//             _menuCard(Icons.assignment, "Orders", Colors.orange, const AdminOrdersPage()),
//             _menuCard(Icons.psychology, "Quiz", Colors.purple, const QuizListPage()),
//             _menuCard(Icons.group, "Users", Colors.teal, const AdminUsersPage()),
//             _menuCard(Icons.payments, "Payments", Colors.indigo, const AdminPaymentHistory()),
//             _menuCard(Icons.thumbs_up_down, "Reviews", Colors.amber, const AdminReviewsPage()),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _drawerTile(IconData icon, String label, Widget page) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.green[700]),
//       title: TText(label),
//       onTap: () {
//         Navigator.pop(context);
//         _nav(page);
//       },
//     );
//   }
//
//   Widget _menuCard(IconData icon, String title, Color color, Widget page) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: InkWell(
//         onTap: () => _nav(page),
//         borderRadius: BorderRadius.circular(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
//               child: Icon(icon, size: 32, color: color),
//             ),
//             const SizedBox(height: 12),
//             TText(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showLanguageDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const TText("Select Language", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _langOption("English", "en"),
//             _langOption("हिंदी", "hi"),
//             _langOption("मराठी", "mr"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _langOption(String name, String code) {
//     return ListTile(
//       title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
//       onTap: () {
//         UserSession.setLanguage(code);
//         setState(() {});
//         Navigator.pop(context);
//       },
//       trailing: UserSession.language == code ? const Icon(Icons.check_circle, color: Colors.green) : null,
//     );
//   }
//
//   Future<void> _handleLogout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
//     }
//   }
// }correted code 2 april


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this line in pubspec.yaml
import 'admin_product_list.dart';
import 'admin_orders_page.dart';
import 'admin_user_page.dart';
import 'admin_payment_history.dart';
import 'QuizListPage.dart';
import 'admin_reviews_page.dart';
import 'login.dart';
import 'user_session.dart';
import 'translated_text.dart';
import 'api_config.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {

  void _nav(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }


  Future<void> _downloadReport(String type) async {

    final String url = "${ApiConfig.baseUrl}generate_report.php?type=$type";
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Download fail zala")),
        );
      }
    }
  }


  void _showReportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TText("Download Sales Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.calendar_view_week, color: Colors.green),
              title: const TText("Weekly Report"),
              onTap: () {
                Navigator.pop(context);
                _downloadReport('weekly');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.blue),
              title: const TText("Monthly Report"),
              onTap: () {
                Navigator.pop(context);
                _downloadReport('monthly');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: const TText("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.g_translate, color: Colors.white, size: 22),
            onPressed: () => _showLanguageDialog(),
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              accountName: const TText("Administrator", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: FutureBuilder<String?>(
                future: SharedPreferences.getInstance().then((prefs) => prefs.getString('userEmail')),
                builder: (context, snapshot) => Text(snapshot.data ?? "admin@smartfarm.com"),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.green),
              ),
            ),
            _drawerTile(Icons.shopping_bag_outlined, "Manage Fertilizers", const AdminProductListPage()),
            _drawerTile(Icons.local_shipping_outlined, "View Orders", const AdminOrdersPage()),
            _drawerTile(Icons.quiz_outlined, "Manage Quiz", const QuizListPage()),
            _drawerTile(Icons.people_outline, "Manage Users", const AdminUsersPage()),
            _drawerTile(Icons.account_balance_wallet_outlined, "Payment History", const AdminPaymentHistory()),
            _drawerTile(Icons.reviews_outlined, "Product Reviews", const AdminReviewsPage()),


            ListTile(
              leading: Icon(Icons.analytics_outlined, color: Colors.green[700]),
              title: const TText("Generate Reports"),
              onTap: () {
                Navigator.pop(context);
                _showReportOptions();
              },
            ),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const TText("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _menuCard(Icons.inventory_2, "Fertilizers", Colors.blue, const AdminProductListPage()),
            _menuCard(Icons.assignment, "Orders", Colors.orange, const AdminOrdersPage()),
            _menuCard(Icons.psychology, "Quiz", Colors.purple, const QuizListPage()),
            _menuCard(Icons.group, "Users", Colors.teal, const AdminUsersPage()),
            _menuCard(Icons.payments, "Payments", Colors.indigo, const AdminPaymentHistory()),
            _menuCard(Icons.thumbs_up_down, "Reviews", Colors.amber, const AdminReviewsPage()),
          ],
        ),
      ),
    );
  }


  Widget _drawerTile(IconData icon, String label, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: TText(label),
      onTap: () {
        Navigator.pop(context);
        _nav(page);
      },
    );
  }

  Widget _menuCard(IconData icon, String title, Color color, Widget page) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _nav(page),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            TText(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const TText("Select Language", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langOption("English", "en"),
            _langOption("हिंदी", "hi"),
            _langOption("मराठी", "mr"),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String name, String code) {
    return ListTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        UserSession.setLanguage(code);
        setState(() {});
        Navigator.pop(context);
      },
      trailing: UserSession.language == code ? const Icon(Icons.check_circle, color: Colors.green) : null,
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
    }
  }
}