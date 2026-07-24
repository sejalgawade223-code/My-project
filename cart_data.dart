import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'api_config.dart';

List<Map<String, dynamic>> cartItems = [];

void addToCart(Map<String, dynamic> product) {
  final index =
  cartItems.indexWhere((item) => item['p_id'] == product['id']);

  if (index != -1) {
    cartItems[index]['quantity'] =
        (cartItems[index]['quantity'] ?? 1) + 1;
  } else {
    cartItems.add({
      'p_id': product['id'],
      'name': product['name'],
      'price': product['price'],
      'image_url': product['image_url'],
      'quantity': 1,
    });
  }
}


Future<void> addToCartDB(Map<String, dynamic> product) async {
  final userId = await SessionManager.getUserId();

  if (userId == null) {
    print("❌ User not logged in");
    return;
  }

  final url =
  Uri.parse(
      "${ApiConfig.baseUrl}add_to_cart.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "product_id": product['id'],
      "product_name": product['name'],
      "price": product['price'],
    }),
  );

  print("ADD CART RESPONSE: ${response.statusCode} | ${response.body}");

  if (response.body.isEmpty) {
    print(" Empty response from server");
    return;
  }

  final data = jsonDecode(response.body);

  if (data['success'] == true) {
    print(" Product added to DB");
  } else {
    print(" DB Error: ${data['error']}");
  }
}


void removeFromCart(int index) {
  if (index >= 0 && index < cartItems.length) {
    cartItems.removeAt(index);
  }
}


void clearCart() {
  cartItems.clear();
}

