
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static Future<void> saveSession({
    required int userId,
    required String email,
    required String name,
    required String address,
    required String contactNo,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("u_id", userId);
    await prefs.setString("email", email);
    await prefs.setString("name", name);
    await prefs.setString("address", address);
    await prefs.setString("contact_no", contactNo);
    await prefs.setString("role", role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("u_id");
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("address");
  }

  static Future<String?> getContactNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("contact_no");
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
