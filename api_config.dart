
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {

  static const String _pcIp = "10.23.250.187";
  static const String _port = "80";

  static String get baseUrl {

    if (kIsWeb) {
     // return "http://localhost/file_api/";
      return "http://10.23.250.187/file_api/";
    }


    if (Platform.isAndroid) {

     return "http://$_pcIp/file_api/";


       //return "http://10.0.2.2/file_api/";
    }

    return "http://$_pcIp/file_api/";
  }
}

