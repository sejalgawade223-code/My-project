import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_model.dart';

class RecommendedProductsService {

  static const String apiUrl = "http://10.0.2.2/file_api/fetch_products.php";

  static Future<List<Product>> fetchRecommendedProducts({
    String cropCategory = '',
    String cropType = '',
    String growthStage = '',
    String problem = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'crop_category': cropCategory,
          'crop_type': cropType,
          'growth_stage': growthStage,
          'problem': problem,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          List<Product> products = [];
          for (var item in jsonData['products']) {
            products.add(Product.fromJson(item));
          }
          return products;
        } else {
          return [];
        }
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }
}
