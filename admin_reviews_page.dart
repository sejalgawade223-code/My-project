import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'translated_text.dart';
class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  List allReviews = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAllReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  Future<void> fetchAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}get_all_reviews_admin.php"),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            allReviews = json.decode(response.body);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: const TText("Product Reviews", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : allReviews.isEmpty
          ? const Center(child: TText("No reviews found.", style: TextStyle(color: Colors.grey)))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: allReviews.length,
          itemBuilder: (context, index) {
            final review = allReviews[index];
            int ratingValue = int.tryParse(review['rating'].toString()) ?? 0;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Product & Rating Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TText(
                            review['product_name'] ?? "Product",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRatingStars(ratingValue),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // --- User Info ---
                    Row(
                      children: [
                        const TText("By", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(": ${review['user_name']}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
                    ),

                    const Divider(height: 24, thickness: 0.8),


                    TText(
                      (review['review'] == null || review['review'].toString().trim().isEmpty)
                          ? "No written review provided."
                          : review['review'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),


                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        review['created_at'] ?? "",
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey[300]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.orangeAccent,
          size: 18,
        );
      }),
    );
  }
}
