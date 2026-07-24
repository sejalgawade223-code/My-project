import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';


class TranslationService {
  static Future<String> translate(String input) async {
    if (UserSession.language == 'en' || input.isEmpty) return input;

    try {
      final url = Uri.parse(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(input)}",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)[0][0][0].toString();
      }
    } catch (e) {
      debugPrint("Translation Error: $e");
    }
    return input;
  }
}


class TText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: TranslationService.translate(text),
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}