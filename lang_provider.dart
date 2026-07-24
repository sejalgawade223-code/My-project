import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  void changeLanguage(String code) async {
    _locale = Locale(code);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lang', code);
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('lang') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }
}
