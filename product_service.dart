

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'product_model.dart';
//
// class ProductService {
//   static const String apiUrl =
//       "http://10.0.2.2/file_api/fetch_products.php";
//
//   static Future<List<Product>> fetchProducts({
//     required String cropCategory,
//     required String cropType,
//     required String growthStage,
//     required String problem,
//   }) async {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         "crop_category": cropCategory,
//         "crop_type": cropType,
//         "growth_stage": growthStage,
//         "problem": problem,
//       },
//     );
//
//     final data = json.decode(response.body);
//
//     if (data["success"] == true) {
//       return (data["products"] as List)
//           .map((e) => Product.fromJson(e))
//           .toList();
//     } else {
//       return [];
//     }
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_model.dart';
import 'api_config.dart';

class ProductService {
  static Future<List<Product>> fetchRecommendations({
    required String problem,
    required String pref,
  }) async {

    final url = Uri.parse(
        "${ApiConfig.baseUrl}get_recommendation.php?problem=$problem&pref=$pref"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error: $e");
    }

    return [];
  }
}
