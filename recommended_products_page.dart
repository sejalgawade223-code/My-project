import 'package:flutter/material.dart';
import 'product_model.dart';
import 'productdetail.dart';
import 'cart_page.dart';
import 'cart_data.dart';
import 'profile_page.dart';
import 'home.dart';
import 'session_manager.dart';
import 'user_session.dart';
import 'translated_text.dart';

class RecommendedProductsPage extends StatefulWidget {
  final List<Product> products;
  const RecommendedProductsPage({super.key, required this.products});

  @override
  State<RecommendedProductsPage> createState() =>
      _RecommendedProductsPageState();
}

class _RecommendedProductsPageState extends State<RecommendedProductsPage> {
  int? userId;
  int _selectedIndex = 0;

  List<Product> filteredProducts = [];
  Set<String> wishlistIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSession();
    filteredProducts = widget.products;
  }



  Future<void> _loadSession() async {
    final id = await SessionManager.getUserId();
    if (mounted) setState(() => userId = id);
  }

  void toggleWishlist(String productId) {
    setState(() {
      if (wishlistIds.contains(productId)) {
        wishlistIds.remove(productId);
      } else {
        wishlistIds.add(productId);
      }
    });
  }

  void applyFilters() {
    setState(() {
      filteredProducts = widget.products.where((product) {
        final name = product.name.toLowerCase();
        return name.contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserSession.languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xfff8f9fa),
          appBar: AppBar(
            backgroundColor: Colors.green[700],
            elevation: 2,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const TText(
              "Suggested For You",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) => _buildEcommerceCard(filteredProducts[index]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => applyFilters(),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.green),
          hintText: "Search fertilizers...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEcommerceCard(Product p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: {
              "p_id": p.pId.toString(),
              "name": p.name,
              "brand": p.brand,
              "price": p.price,
              "description": p.desc,
              "description_mr": p.descriptionMr,
              "description_hi": p.descriptionHi,
              "image_url": p.image,
              "type": p.type,
              "stock_quantity": p.stock,
            }),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.network(
                        p.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5, right: 5,
                    child: IconButton(
                      icon: Icon(wishlistIds.contains(p.pId.toString()) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: () => toggleWishlist(p.pId.toString()),
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
                  TText(p.brand, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  TText(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text("₹${p.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Text("₹${(double.parse(p.price) * 1.2).toInt()}",
                          style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: TText("No products found", style: TextStyle(color: Colors.grey)));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index == _selectedIndex) return;
        setState(() => _selectedIndex = index);
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())).then((_) => setState(() {}));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => InternalWishlistPage(allProducts: widget.products, wishlistIds: wishlistIds, onToggle: toggleWishlist)));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green[700],
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
            icon: Stack(children: [
              const Icon(Icons.shopping_bag_outlined),
              if (cartItems.isNotEmpty) Positioned(right: 0, child: CircleAvatar(radius: 7, backgroundColor: Colors.red, child: Text('${cartItems.length}', style: const TextStyle(fontSize: 8, color: Colors.white))))
            ]),
            label: "Cart"
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}

class InternalWishlistPage extends StatelessWidget {
  final List<Product> allProducts;
  final Set<String> wishlistIds;
  final Function(String) onToggle;
  const InternalWishlistPage({super.key, required this.allProducts, required this.wishlistIds, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final list = allProducts.where((p) => wishlistIds.contains(p.pId.toString())).toList();
    return Scaffold(
      appBar: AppBar(title: const TText("My Wishlist"), backgroundColor: Colors.green[700]),
      body: list.isEmpty
          ? const Center(child: TText("Your wishlist is empty!"))
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final p = list[index];
          return ListTile(
            leading: Image.network(p.image, width: 50),
            title: TText(p.name),
            subtitle: Text("₹${p.price}"),
            trailing: IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () => onToggle(p.pId.toString())),
          );
        },
      ),
    );
  }
}