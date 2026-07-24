import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'order_detail_page.dart';
import 'api_config.dart';
import 'translated_text.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List cartItems = [];
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final uId = await SessionManager.getUserId();
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}cart_actions.php"),
      body: {"action": "fetch", "u_id": uId.toString()},
    );
    try {
      cartItems = json.decode(res.body);
    } catch (_) {
      cartItems = [];
    }
    setState(() => isLoading = false);
  }

  double totalAmount() {
    double total = 0;
    for (var i in cartItems) {
      double originalPrice = double.tryParse(i['price'].toString()) ?? 0;
      double discountedPrice = originalPrice * 0.75;
      total += discountedPrice * int.parse(i['quantity'].toString());
    }
    return total;
  }

  Future<void> updateQty(String cartId, String type) async {
    await http.post(
      Uri.parse("${ApiConfig.baseUrl}cart_actions.php"),
      body: {"action": "update_qty", "cart_id": cartId, "type": type},
    );
    fetchCart();
  }

  Future<void> removeItem(String cartId) async {
    await http.post(
      Uri.parse("${ApiConfig.baseUrl}cart_actions.php"),
      body: {"action": "remove", "cart_id": cartId},
    );
    fetchCart();
  }

  void showDeleteDialog(String cartId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TText(
          "Remove Product",
          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
        ),
        content: const TText("Remove this item from your supply cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TText("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              removeItem(cartId);
            },
            child: const TText("Remove"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        title: const TText("Shopping Bag",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green.shade800))
          : cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 80, color: Colors.green.shade200),
            const SizedBox(height: 16),
            const TText("Your cart is empty",
                style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w500)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: cartItems.length,
              itemBuilder: (_, i) {
                final item = cartItems[i];
                double originalPrice = double.tryParse(item['price'].toString()) ?? 0;
                double discountedPrice = originalPrice * 0.75;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade900.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 85, height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.shade50,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "${ApiConfig.baseUrl}${item['image_url']}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.grass, color: Colors.green.shade200),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TText(
                              item['name'],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${discountedPrice.toStringAsFixed(0)}",
                              style: TextStyle(
                                  color: Colors.lightGreen.shade700,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyBtn(Icons.remove, () => updateQty(item['cart_id'], "decrement")),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      item['quantity'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900),
                                    ),
                                  ),
                                  _qtyBtn(Icons.add, () => updateQty(item['cart_id'], "increment")),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showDeleteDialog(item['cart_id']),
                        icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade300),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(blurRadius: 15, color: Colors.green.shade900.withOpacity(0.1))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TText("Grand Total", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        "₹${totalAmount().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.green.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        shadowColor: Colors.green.shade200,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(
                              cartItems: cartItems,
                              totalAmount: totalAmount(),
                            ),
                          ),
                        );
                      },
                      child: const TText("PLACE ORDER",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: Colors.green.shade800),
      ),
    );
  }
}

