import 'dart:convert';
import 'package:http/http.dart' as http;

class AutoTranslator {
  static Future<String> translateText(String text, String targetLang) async {
    // Basic checks
    if (text.trim().isEmpty || text == "N/A" || targetLang == 'en') return text;

    try {
      // Direct Google Translate Free API call
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Response se translation nikalne ka logic
        final data = json.decode(response.body);
        return data[0][0][0].toString();
      } else {
        return text; // Error hone par original text dikhao
      }
    } catch (e) {
      print("API Error: $e");
      return text;
    }
  }
}