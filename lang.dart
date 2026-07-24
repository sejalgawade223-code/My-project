// import 'package:flutter/material.dart';
//
// class AppLocalizations {
//   final Locale locale;
//   AppLocalizations(this.locale);
//
//   static AppLocalizations of(BuildContext context) =>
//       Localizations.of(context, AppLocalizations)!;
//
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//   _AppLocalizationsDelegate();
//
//   static const Map<String, Map<String, String>> _localizedValues = {
//     // ================= ENGLISH =================
//     'en': {
//       // ----- Admin -----
//       'admin': 'Admin',
//       'dashboard': 'Dashboard',
//       'dashboardClicked': 'Dashboard clicked',
//       'manageFertilizers': 'Manage Fertilizers',
//       'viewOrders': 'View Orders',
//       'manageQuiz': 'Manage Quiz Questions',
//       'manageUsers': 'Manage Users',
//       'paymentHistory': 'Payment History',
//       'productReviews': 'Product Reviews',
//       'logout': 'Logout',
//       'logoutSuccess': 'Logged out successfully',
//
//       // ----- Add Quiz Question -----
//       'addQuizQuestion': 'Add Quiz Question',
//       'category': 'Category',
//       'question': 'Question',
//       'option1': 'Option 1',
//       'option2': 'Option 2',
//       'option3': 'Option 3',
//       'option4': 'Option 4',
//       'saveQuestion': 'Save Question',
//       'required': 'Required',
//       'serverError': 'Server Error',
//     },
//
//     // ================= HINDI =================
//     'hi': {
//       // ----- Admin -----
//       'admin': 'प्रशासक',
//       'dashboard': 'डैशबोर्ड',
//       'dashboardClicked': 'डैशबोर्ड चुना गया',
//       'manageFertilizers': 'उर्वरक प्रबंधन',
//       'viewOrders': 'ऑर्डर देखें',
//       'manageQuiz': 'क्विज़ प्रबंधन',
//       'manageUsers': 'उपयोगकर्ता प्रबंधन',
//       'paymentHistory': 'भुगतान इतिहास',
//       'productReviews': 'उत्पाद समीक्षाएं',
//       'logout': 'लॉगआउट',
//       'logoutSuccess': 'सफलतापूर्वक लॉगआउट',
//
//       // ----- Add Quiz Question -----
//       'addQuizQuestion': 'प्रश्न जोड़ें',
//       'category': 'श्रेणी',
//       'question': 'प्रश्न',
//       'option1': 'विकल्प 1',
//       'option2': 'विकल्प 2',
//       'option3': 'विकल्प 3',
//       'option4': 'विकल्प 4',
//       'saveQuestion': 'प्रश्न सहेजें',
//       'required': 'आवश्यक',
//       'serverError': 'सर्वर त्रुटि',
//     },
//
//     // ================= MARATHI =================
//     'mr': {
//       // ----- Admin -----
//       'admin': 'प्रशासक',
//       'dashboard': 'डॅशबोर्ड',
//       'dashboardClicked': 'डॅशबोर्ड निवडला',
//       'manageFertilizers': 'खते व्यवस्थापन',
//       'viewOrders': 'ऑर्डर पहा',
//       'manageQuiz': 'क्विझ व्यवस्थापन',
//       'manageUsers': 'वापरकर्ता व्यवस्थापन',
//       'paymentHistory': 'पेमेंट इतिहास',
//       'productReviews': 'उत्पादन पुनरावलोकने',
//       'logout': 'लॉगआउट',
//       'logoutSuccess': 'यशस्वीरित्या लॉगआउट',
//
//       // ----- Add Quiz Question -----
//       'addQuizQuestion': 'प्रश्न जोडा',
//       'category': 'वर्ग',
//       'question': 'प्रश्न',
//       'option1': 'पर्याय 1',
//       'option2': 'पर्याय 2',
//       'option3': 'पर्याय 3',
//       'option4': 'पर्याय 4',
//       'saveQuestion': 'प्रश्न जतन करा',
//       'required': 'आवश्यक',
//       'serverError': 'सर्व्हर त्रुटी',
//     },
//   };
//
//   String _t(String key) =>
//       _localizedValues[locale.languageCode]?[key] ??
//           _localizedValues['en']![key]!;
//
//   // ======== ADMIN GETTERS ========
//   String get admin => _t('admin');
//   String get dashboard => _t('dashboard');
//   String get dashboardClicked => _t('dashboardClicked');
//   String get manageFertilizers => _t('manageFertilizers');
//   String get viewOrders => _t('viewOrders');
//   String get manageQuiz => _t('manageQuiz');
//   String get manageUsers => _t('manageUsers');
//   String get paymentHistory => _t('paymentHistory');
//   String get productReviews => _t('productReviews');
//   String get settings => _t('settings');
//   String get logout => _t('logout');
//   String get logoutSuccess => _t('logoutSuccess');
//
//   // ======== QUIZ GETTERS ========
//   String get addQuizQuestion => _t('addQuizQuestion');
//   String get category => _t('category');
//   String get question => _t('question');
//   String get option1 => _t('option1');
//   String get option2 => _t('option2');
//   String get option3 => _t('option3');
//   String get option4 => _t('option4');
//   String get saveQuestion => _t('saveQuestion');
//   String get required => _t('required');
//   String get serverError => _t('serverError');
// }
//
// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();
//
//   @override
//   bool isSupported(Locale locale) =>
//       ['en', 'hi', 'mr'].contains(locale.languageCode);
//
//   @override
//   Future<AppLocalizations> load(Locale locale) async {
//     return AppLocalizations(locale);
//   }
//
//   @override
//   bool shouldReload(_) => false;
// }


import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    // ================= ENGLISH =================
    'en': {
      // ----- Admin -----
      'admin': 'Admin',
      'dashboard': 'Dashboard',
      'dashboardClicked': 'Dashboard clicked',
      'manageFertilizers': 'Manage Fertilizers',
      'viewOrders': 'View Orders',
      'manageQuiz': 'Manage Quiz Questions',
      'manageUsers': 'Manage Users',
      'paymentHistory': 'Payment History',
      'productReviews': 'Product Reviews',
      'logout': 'Logout',
      'logoutSuccess': 'Logged out successfully',

      // ----- Login & Auth -----
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'signUpPrompt': "Don't have an account? Sign Up",
      'fillAllFields': '⚠️ Please fill all fields',
      'loginSuccess': '✅ Login Successful',
      'loginFailed': 'Login failed',
      'serverError': 'Server Error',

      // ----- Add Quiz Question -----
      'addQuizQuestion': 'Add Quiz Question',
      'category': 'Category',
      'question': 'Question',
      'option1': 'Option 1',
      'option2': 'Option 2',
      'option3': 'Option 3',
      'option4': 'Option 4',
      'saveQuestion': 'Save Question',
      'required': 'Required',
    },

    // ================= HINDI =================
    'hi': {
      'admin': 'प्रशासक',
      'dashboard': 'डैशबोर्ड',
      'dashboardClicked': 'डैशबोर्ड चुना गया',
      'manageFertilizers': 'उर्वरक प्रबंधन',
      'viewOrders': 'ऑर्डर देखें',
      'manageQuiz': 'क्विज़ प्रबंधन',
      'manageUsers': 'उपयोगकर्ता प्रबंधन',
      'paymentHistory': 'भुगतान इतिहास',
      'productReviews': 'उत्पाद समीक्षाएं',
      'logout': 'लॉगआउट',
      'logoutSuccess': 'सफलतापूर्वक लॉगआउट',

      'login': 'लॉगिन',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'signUpPrompt': 'खाता नहीं है? साइन अप करें',
      'fillAllFields': '⚠️ कृपया सभी फ़ील्ड भरें',
      'loginSuccess': '✅ लॉगिन सफल रहा',
      'loginFailed': 'लॉगिन विफल रहा',
      'serverError': 'सर्वर त्रुटि',

      'addQuizQuestion': 'प्रश्न जोड़ें',
      'category': 'श्रेणी',
      'question': 'प्रश्न',
      'option1': 'विकल्प 1',
      'option2': 'विकल्प 2',
      'option3': 'विकल्प 3',
      'option4': 'विकल्प 4',
      'saveQuestion': 'प्रश्न सहेजें',
      'required': 'आवश्यक',
    },

    // ================= MARATHI =================
    'mr': {
      'admin': 'प्रशासक',
      'dashboard': 'डॅशबोर्ड',
      'dashboardClicked': 'डॅशबोर्ड निवडला',
      'manageFertilizers': 'खते व्यवस्थापन',
      'viewOrders': 'ऑर्डर पहा',
      'manageQuiz': 'क्विझ व्यवस्थापन',
      'manageUsers': 'वापरकर्ता व्यवस्थापन',
      'paymentHistory': 'पेमेंट इतिहास',
      'productReviews': 'उत्पादन पुनरावलोकने',
      'logout': 'लॉगआउट',
      'logoutSuccess': 'यशस्वीरित्या लॉगआउट',

      'login': 'लॉगिन',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgotPassword': 'पासवर्ड विसरलात?',
      'signUpPrompt': 'खाते नाही का? साइन अप करा',
      'fillAllFields': '⚠️ कृपया सर्व माहिती भरा',
      'loginSuccess': '✅ लॉगिन यशस्वी',
      'loginFailed': 'लॉगिन अयशस्वी',
      'serverError': 'सर्व्हर त्रुटी',

      'addQuizQuestion': 'प्रश्न जोडा',
      'category': 'वर्ग',
      'question': 'प्रश्न',
      'option1': 'पर्याय 1',
      'option2': 'पर्याय 2',
      'option3': 'पर्याय 3',
      'option4': 'पर्याय 4',
      'saveQuestion': 'प्रश्न जतन करा',
      'required': 'आवश्यक',
    },
  };

  String _t(String key) =>
      _localizedValues[locale.languageCode]?[key] ??
          _localizedValues['en']![key]!;

  // ======== LOGIN GETTERS ========
  String get login => _t('login');
  String get email => _t('email');
  String get password => _t('password');
  String get forgotPassword => _t('forgotPassword');
  String get signUpPrompt => _t('signUpPrompt');
  String get fillAllFields => _t('fillAllFields');
  String get loginSuccess => _t('loginSuccess');
  String get loginFailed => _t('loginFailed');

  // ======== ADMIN GETTERS ========
  String get admin => _t('admin');
  String get dashboard => _t('dashboard');
  String get dashboardClicked => _t('dashboardClicked');
  String get manageFertilizers => _t('manageFertilizers');
  String get viewOrders => _t('viewOrders');
  String get manageQuiz => _t('manageQuiz');
  String get manageUsers => _t('manageUsers');
  String get paymentHistory => _t('paymentHistory');
  String get productReviews => _t('productReviews');
  String get logout => _t('logout');
  String get logoutSuccess => _t('logoutSuccess');

  // ======== QUIZ GETTERS ========
  String get addQuizQuestion => _t('addQuizQuestion');
  String get category => _t('category');
  String get question => _t('question');
  String get option1 => _t('option1');
  String get option2 => _t('option2');
  String get option3 => _t('option3');
  String get option4 => _t('option4');
  String get saveQuestion => _t('saveQuestion');
  String get required => _t('required');
  String get serverError => _t('serverError');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_) => false;
}