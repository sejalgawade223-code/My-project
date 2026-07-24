import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addToCart(BuildContext context, int productId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? uId = prefs.getInt('u_id');

  if (uId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login first")),
    );
    return;
  }

  final response = await http.post(
    Uri.parse("http://10.0.2.2/file_api/add_to_cart.php"),
    body: {
      "u_id": uId.toString(),
      "p_id": productId.toString(),
    },
  );

  final data = jsonDecode(response.body);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(data['message'])),
  );
}
