// import 'package:flutter/material.dart';
//
// class UserSession {
//   static String? userId;
//   static String? name;
//   static String? email;
//   static String? profileImageUrl;
//
//   // Language support
//   static String language = 'en'; // default English
//
//   // Notifier to notify pages when language changes
//   static ValueNotifier<String> languageNotifier = ValueNotifier(language);
//
//   static void setLanguage(String lang) {
//     language = lang;
//     languageNotifier.value = lang; // notify all listeners
//   }
//
//   static void clear() {
//     userId = null;
//     name = null;
//     email = null;
//     profileImageUrl = null;
//     setLanguage('en'); // reset language on logout
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? userId;
  static String? name;
  static String? email;
  static String? profileImageUrl;


  static String language = 'en';


  static ValueNotifier<String> languageNotifier = ValueNotifier(language);


  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString('user_lang') ?? 'en';
    languageNotifier.value = language;
  }


  static Future<void> setLanguage(String lang) async {
    language = lang;
    languageNotifier.value = lang;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_lang', lang);
  }

  static void clear() async {
    userId = null;
    name = null;
    email = null;
    profileImageUrl = null;


    // await setLanguage('en');


  }
}