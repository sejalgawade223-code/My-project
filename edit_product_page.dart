import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'user_session.dart';
import 'translated_text.dart';

class EditProductPage extends StatefulWidget {
  final Map product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController name, price, desc;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.product['name']?.toString() ?? "");
    price = TextEditingController(text: widget.product['price']?.toString() ?? "");
    desc = TextEditingController(text: widget.product['description']?.toString() ?? "");
  }



  Future<void> updateProduct() async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}update_product.php"),
        body: {
          "id": widget.product['id']?.toString() ?? widget.product['p_id']?.toString(), // दोन्ही शक्य कीज तपासल्या
          "name": name.text,
          "price": price.text,
          "description": desc.text,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TText("Edit Product"),
        backgroundColor: Colors.green,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: UserSession.languageNotifier,
        builder: (context, lang, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                _buildTranslatedField(name, "Name"),
                _buildTranslatedField(price, "Price", keyboardType: TextInputType.number),
                _buildTranslatedField(desc, "Description", maxLines: 3),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: updateProduct,
                    child: const TText(
                      "Update",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildTranslatedField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return FutureBuilder<String>(

      future: UserSession.language == 'en'
          ? Future.value(label)
          : http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(label)}")).then((res) => jsonDecode(res.body)[0][0][0].toString()),
      builder: (context, snapshot) {
        return TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: snapshot.data ?? label,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    desc.dispose();
    super.dispose();
  }
}