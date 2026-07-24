import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'productdetail.dart';
import 'user_session.dart';
import 'profile_page.dart';
import 'home.dart';
import 'api_config.dart';
import 'translated_text.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List products = [];
  List filteredProducts = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;
  String selectedCategory = 'All';
  Set<String> wishlistIds = {};


  final Map<String, IconData> categoryIcons = {
    'All': Icons.apps,
    'Fertilizer': Icons.science,
    'Both/Mixed': Icons.bug_report,
    'Bio-fertilizer': Icons.grass,
    'Organic': Icons.eco,
  };

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String urlString = "${ApiConfig.baseUrl}get_products.php";
    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data is List ? data : [];
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final category = product['type']?.toString().toLowerCase().trim() ?? '';
        final matchesSearch = name.contains(searchController.text.toLowerCase());
        final matchesCategory =
            selectedCategory == 'All' || category.contains(selectedCategory.toLowerCase());
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void toggleWishlist(dynamic productId) {
    final id = productId.toString();
    setState(() {
      wishlistIds.contains(id) ? wishlistIds.remove(id) : wishlistIds.add(id);
    });
  }

  void showCategorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          children: categoryIcons.keys.map((categoryKey) {
            return ListTile(
              leading: Icon(categoryIcons[categoryKey], color: Colors.green),

              title: TText(categoryKey),
              trailing: selectedCategory == categoryKey
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedCategory = categoryKey;
                  applyFilters();
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TText("Search products"),
            const Text(" • "),
            TText(selectedCategory),
          ],
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (_) => applyFilters(),
              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                double originalPrice = double.tryParse(product['price'].toString()) ?? 0;
                double discountedPrice = originalPrice * 0.75;

                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(product['image_url'] ?? 'https://via.placeholder.com/150', fit: BoxFit.cover, width: double.infinity),
                              ),
                              Positioned(
                                top: 0, right: 0,
                                child: IconButton(
                                  icon: Icon(wishlistIds.contains(product['p_id'].toString()) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                                  onPressed: () => toggleWishlist(product['p_id']),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TText(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold),),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text("₹${discountedPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 5),
                                  Text("₹${originalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                ],
                              ),
                              TText(product['type'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: UserSession.languageNotifier,
        builder: (context, lang, _) {
          return BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: Colors.green,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() => currentIndex = index);
              if (index == 1) showCategorySheet();
              if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistPage(products: products, wishlistIds: wishlistIds, toggleWishlist: toggleWishlist)));
              if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), // ✅ खालील लेबल आपोआप TText लॉजिकने बदलतील (जर तुम्ही BottomNav मध्ये TText वापरला असेल)
              BottomNavigationBarItem(icon: Icon(Icons.category), label: "Category"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Wishlist"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "You"),
            ],
          );
        },
      ),
    );
  }
}

// ================= WISHLIST PAGE =================
class WishlistPage extends StatelessWidget {
  final List products;
  final Set<String> wishlistIds;
  final Function toggleWishlist;

  const WishlistPage({super.key, required this.products, required this.wishlistIds, required this.toggleWishlist});

  @override
  Widget build(BuildContext context) {
    final wishlistProducts = products.where((p) => wishlistIds.contains(p['p_id'].toString())).toList();

    return Scaffold(
      appBar: AppBar(title: const TText("My Wishlist"), backgroundColor: Colors.green),
      body: wishlistProducts.isEmpty
          ? const Center(child: TText("Wishlist is empty"))
          : ListView.builder(
        itemCount: wishlistProducts.length,
        itemBuilder: (context, index) {
          final product = wishlistProducts[index];
          return ListTile(
            leading: Image.network(product['image_url'] ?? 'https://via.placeholder.com/150', width: 50, fit: BoxFit.cover),
            title: TText(product['name']),
            subtitle: TText(product['type'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => toggleWishlist(product['p_id']),
            ),
          );
        },
      ),
    );
  }
}