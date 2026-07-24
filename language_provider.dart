import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }


  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }


  Future<void> changeLanguage(String langCode) async {
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }
}