import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'quiz_page1.dart';
import 'browse_fertilizer_page.dart';
import 'session_manager.dart';
import 'login.dart';
import 'user_session.dart';
import 'translated_text.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  String _userName = "Guest";
  String _userEmail = "";
  String _userAddress = "";
  String _userContact = "";
  String _userRole = "customer";

  String _currentDate = "";
  String _currentTemp = "";
  String _currentHumidity = "";


  final List<String> _tips = [
    "Optimize your yield by balancing N-P-K levels; precise nutrient management prevents soil fatigue.",
    "Check soil moisture at a depth of 6 inches for the most accurate reading before irrigation.",
    "Integrated Pest Management (IPM) reduces chemical reliance by using natural predators.",
  ];
  String _currentTip = "";

  void _generateDynamicWeather() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM dd');
    final random = Random();
    int daySeed = now.day + now.month;
    int temp = 25 + (daySeed % 10);
    int humidity = 50 + (daySeed % 20);
    setState(() {
      _currentDate = formatter.format(now);
      _currentTemp = "$temp°C";
      _currentHumidity = "$humidity%";
      _currentTip = _tips[random.nextInt(_tips.length)];
    });
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _bannerMessages = [
    "Check Soil Health Regularly 🌾",
    "Use Organic Fertilizers for Better Yield 🍃",
    "Smart Farming, Better Future 🚜",
  ];

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _generateDynamicWeather();
    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < 2) { _currentPage++; } else { _currentPage = 0; }
      if (_pageController.hasClients) {
        _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
      }
    });
  }

  Future<void> _loadSessionData() async {
    final name = await SessionManager.getName();
    final email = await SessionManager.getEmail();
    final address = await SessionManager.getAddress();
    final contact = await SessionManager.getContactNo();
    final role = await SessionManager.getRole();
    setState(() {
      _userName = name ?? "Guest";
      _userEmail = email ?? "";
      _userAddress = address ?? "";
      _userContact = contact ?? "";
      _userRole = role ?? "customer";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(

        title: const TText("FertiSmart", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        backgroundColor: const Color(0xFF81C784),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              accountName: TText(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Row(
                children: [
                  Expanded(child: Text(_userEmail)),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 15),
                    onPressed: () async {
                      final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProfilePage(
                                name: _userName,
                                email: _userEmail,
                                address: _userAddress,
                                contactNo: _userContact,
                                role: _userRole,
                              )
                          )
                      );
                      if (updated == true) _loadSessionData();
                    },
                  ),
                ],
              ),
              currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 45, color: Color(0xFF2E7D32))),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context, Icons.home, "Home", () => Navigator.pop(context)),
                  _drawerItem(context, Icons.quiz_outlined, "Start Quiz", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage()))),
                  _drawerItem(context, Icons.eco_outlined, "Browse Fertilizers", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerHomePage()))),
                  _drawerItem(context, Icons.language, "Languages", () { Navigator.pop(context); _showLanguageDialog(); }),
                ],
              ),
            ),
            const Divider(height: 1),
            _drawerItem(
              context,
              Icons.logout_rounded,
              "Logout",
                  () async {
                await SessionManager.clearSession();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  LoginPage()), (route) => false);
              },
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(Icons.wb_sunny_rounded, _currentTemp, "Temp"),
                      _buildMiniStat(Icons.water_drop_rounded, _currentHumidity, "Humidity"),
                      _buildMiniStat(Icons.calendar_month_rounded, _currentDate, "Date"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerMessages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: TText(_bannerMessages[index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const TText("Welcome to Smart Farming App 🌱", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)), textAlign: TextAlign.center),
                const SizedBox(height: 25),
                _buildActionCard(title: "Start Quiz", subtitle: "Select Best Fertilizer for Your Crops", icon: Icons.quiz_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage()))),
                const SizedBox(height: 15),
                _buildActionCard(title: "Browse Fertilizers", subtitle: "Shop Quality Products", icon: Icons.shopping_bag_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerHomePage()))),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.orange),
                          const SizedBox(width: 10),
                          const TText("Daily Farming Tip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TText(_currentTip, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        TText(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: const Color(0xFF2E7D32), size: 32)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TText(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), TText(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600]))])),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color iconColor = const Color(0xFF2E7D32)}) {
    return ListTile(leading: Icon(icon, color: iconColor), title: TText(label, style: const TextStyle(fontWeight: FontWeight.w600)), onTap: onTap);
  }

  void _showLanguageDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const TText("Select Language"), content: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: const Text("English"), onTap: () { UserSession.setLanguage("en"); Navigator.pop(context); }),
      ListTile(title: const Text("Hindi"), onTap: () { UserSession.setLanguage("hi"); Navigator.pop(context); }),
      ListTile(title: const Text("Marathi"), onTap: () { UserSession.setLanguage("mr"); Navigator.pop(context); }),
    ])));
  }
}

// --- EDIT PROFILE PAGE ---
class EditProfilePage extends StatefulWidget {
  final String name, email, address, contactNo, role;
  const EditProfilePage({super.key, required this.name, required this.email, required this.address, required this.contactNo, required this.role});
  @override State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameC, emailC, addrC, contC;
  @override void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.name);
    emailC = TextEditingController(text: widget.email);
    addrC = TextEditingController(text: widget.address);
    contC = TextEditingController(text: widget.contactNo);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TText("Edit Profile"), backgroundColor: const Color(0xFF2E7D32)),
      body: Padding(padding: const EdgeInsets.all(25), child: Column(children: [
        TextField(controller: nameC, decoration: const InputDecoration(labelText: "Name")),
        TextField(controller: emailC, decoration: const InputDecoration(labelText: "Email")),
        TextField(controller: addrC, decoration: const InputDecoration(labelText: "Address")),
        TextField(controller: contC, decoration: const InputDecoration(labelText: "Contact No")),
        const SizedBox(height: 30),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 50)),
            onPressed: () async {
              await SessionManager.saveSession(
                userId: await SessionManager.getUserId() ?? 0,
                name: nameC.text,
                email: emailC.text,
                address: addrC.text,
                contactNo: contC.text,
                role: widget.role,
              );
              Navigator.pop(context, true);
            },
            child: const TText("Save Changes", style: TextStyle(color: Colors.white))
        ),
      ])),
    );
  }
}