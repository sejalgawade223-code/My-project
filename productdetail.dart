import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import 'cart_data.dart';
import 'login.dart';
import 'session_manager.dart';
import 'cart_page.dart';
import 'order_detail_page.dart';
import 'api_config.dart';
import 'translated_text.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ScrollController _scrollController = ScrollController();

  String _getLanguageDescription() {
    final p = widget.product;
    switch (UserSession.language) {
      case 'mr':
        return (p['description_mr'] != null && p['description_mr'].toString().isNotEmpty)
            ? p['description_mr']
            : (p['desc'] ?? p['description'] ?? '');
      case 'hi':
        return (p['description_hi'] != null && p['description_hi'].toString().isNotEmpty)
            ? p['description_hi']
            : (p['desc'] ?? p['description'] ?? '');
      default:
        return p['desc'] ?? p['description'] ?? '';
    }
  }

  double avgRating = 0;
  int totalRatings = 0;
  Map<int, int> ratingCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  List reviews = [];

  @override
  void initState() {
    super.initState();
    fetchRatings();
    fetchReviews();
  }

  Future<void> fetchRatings() async {
    final productId = widget.product['p_id'] ?? widget.product['id'];
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}get_ratings.php?p_id=$productId"));
      final data = json.decode(response.body);
      setState(() {
        avgRating = (data['average'] ?? 0).toDouble();
        totalRatings = data['total'] ?? 0;
        ratingCount[5] = data['five'] ?? 0;
        ratingCount[4] = data['four'] ?? 0;
        ratingCount[3] = data['three'] ?? 0;
        ratingCount[2] = data['two'] ?? 0;
        ratingCount[1] = data['one'] ?? 0;
      });
    } catch (e) { debugPrint("Rating Error: $e"); }
  }

  Future<void> fetchReviews() async {
    final productId = widget.product['p_id'] ?? widget.product['id'];
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}get_reviews.php?p_id=$productId"));
      setState(() { reviews = json.decode(response.body); });
    } catch (e) { debugPrint("Review Error: $e"); }
  }

  void showReviewDialog({Map? existingReview}) async {
    int selectedRating = existingReview?['rating'] ?? 5;
    TextEditingController reviewController = TextEditingController(text: existingReview?['review'] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const TText("Write Review"),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.orange),
                      onPressed: () => setDialogState(() { selectedRating = index + 1; }),
                    );
                  }),
                ),
                _buildTranslatedField(reviewController, "Write your review"),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final uId = await SessionManager.getUserId();
              final productId = widget.product['p_id'] ?? widget.product['id'];
              await http.post(Uri.parse("${ApiConfig.baseUrl}add_review.php"),
                body: {
                  "review_id": existingReview?['id']?.toString() ?? "",
                  "p_id": productId.toString(),
                  "u_id": uId.toString(),
                  "rating": selectedRating.toString(),
                  "review": reviewController.text,
                },
              );
              Navigator.pop(context);
              fetchRatings();
              fetchReviews();
            },
            child: const TText("Submit"),
          )
        ],
      ),
    );
  }

  Future<void> deleteReview(int pId, int uId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const TText("Delete Review"),
        content: const TText("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const TText("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const TText("Delete")),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    await http.post(Uri.parse("${ApiConfig.baseUrl}delete_review.php"),
      body: {"p_id": pId.toString(), "u_id": uId.toString()},
    );
    fetchRatings();
    fetchReviews();
  }

  Widget _buildTranslatedField(TextEditingController ctrl, String hint) {
    return FutureBuilder<String>(
      future: UserSession.language == 'en'
          ? Future.value(hint)
          : http.get(Uri.parse("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=${UserSession.language}&dt=t&q=${Uri.encodeComponent(hint)}"))
          .then((res) => jsonDecode(res.body)[0][0][0].toString()),
      builder: (context, snapshot) {
        return TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: snapshot.data ?? hint),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    double originalPrice = double.tryParse(product['price'].toString()) ?? 0;
    double discountedPrice = originalPrice * 0.75;


    int currentStock = int.tryParse(product['stock_quantity']?.toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const TText("Product Details"),
        backgroundColor: Colors.green,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())).then((_) => setState(() {}))),
              if (cartItems.isNotEmpty)
                Positioned(right: 6, top: 6, child: CircleAvatar(radius: 9, backgroundColor: Colors.red, child: Text(cartItems.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)))),
            ],
          )
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(product['image_url'] ?? 'https://via.placeholder.com/300', fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TText(product['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TText(product['type'] ?? '', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text("₹${discountedPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Text("₹${originalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                          child: const TText("25% OFF", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),


                    if (currentStock <= 0) ...[
                      const SizedBox(height: 8),
                      const TText(
                        "Out of Stock",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 12),
                    TText(_getLanguageDescription(), style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                    const Divider(height: 40),

                    const TText("Customer Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: List.generate(5, (i) => Icon(i < avgRating.round() ? Icons.star : Icons.star_border, color: Colors.orange, size: 20))),
                            Text("$totalRatings ratings", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => showReviewDialog(),
                      child: const TText("Write a Review"),
                    ),
                    const SizedBox(height: 20),
                    ...reviews.map((review) => Card(
                      child: ListTile(
                        title: Row(children: List.generate(review['rating'], (index) => const Icon(Icons.star, color: Colors.orange, size: 16))),
                        subtitle: TText(review['review'] ?? ""),
                        trailing: FutureBuilder(
                          future: SessionManager.getUserId(),
                          builder: (context, snap) {
                            if (snap.data?.toString() == review['u_id'].toString()) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showReviewDialog(existingReview: review)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteReview(review['p_id'], review['u_id'])),
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const TText("Add to Cart", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {

                  if (currentStock <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TText("This product is out of stock")));
                    return;
                  }

                  final uId = await SessionManager.getUserId();
                  if (uId == null) { Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())); return; }
                  final productId = widget.product['p_id'] ?? widget.product['id'];
                  final response = await http.post(Uri.parse("${ApiConfig.baseUrl}add_to_cart.php"), body: {"u_id": uId.toString(), "p_id": productId.toString(), "price": discountedPrice.toStringAsFixed(2)});
                  final data = json.decode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TText(data['message'])));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: const TText("Buy Now", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {

                  if (currentStock <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TText("This product is out of stock")));
                    return;
                  }

                  final uId = await SessionManager.getUserId();
                  if (uId == null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(redirectToOrder: true, productToAdd: product)));
                  } else {
                    final buyNowCart = [{"p_id": product['p_id'], "name": product['name'], "price": discountedPrice.toStringAsFixed(2), "quantity": 1}];
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(cartItems: buyNowCart, totalAmount: discountedPrice)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



