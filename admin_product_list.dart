import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_product_page.dart';
import 'api_config.dart';
import 'translated_text.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  Set<String> selectedProductIds = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}fetch_admin_product.php"));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List) {
          if (mounted) {
            setState(() {
              products = List<Map<String, dynamic>>.from(decoded);
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint(" Fetch error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }


  void _showRestockDialog(Map<String, dynamic> product) {
    final TextEditingController qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: TText("Add Stock: ${product['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Stock: ${product['stock_quantity']}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity to Add",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TText("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (qtyController.text.isNotEmpty) {
                await _updateStockOnServer(product['p_id'].toString(), qtyController.text);
                Navigator.pop(context);
                fetchProducts();
              }
            },
            child: const TText("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStockOnServer(String pId, String qty) async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}restock_product.php"),
        body: {"p_id": pId, "added_quantity": qty},
      );
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }


  Future<void> deleteBulkProducts() async {
    try {
      String idsToDelete = selectedProductIds.join(',');
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}delete_admin_product.php"),
        body: {"p_id": idsToDelete, "bulk": "true"},
      );
      setState(() {
        isSelectionMode = false;
        selectedProductIds.clear();
      });
      fetchProducts();
    } catch (e) {
      debugPrint(" Bulk Delete error: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}delete_admin_product.php"),
        body: {"p_id": id},
      );
      fetchProducts();
    } catch (e) {
      debugPrint(" Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: isSelectionMode
            ? Text("${selectedProductIds.length} Selected", style: const TextStyle(color: Colors.white))
            : const TText("Manage Products", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              isSelectionMode = false;
              selectedProductIds.clear();
            });
          },
        )
            : null,
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showBulkDeleteDialog(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          ).then((_) => fetchProducts());
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : products.isEmpty
          ? const Center(child: TText("No products found", style: TextStyle(color: Colors.grey)))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemCount: products.length,
          itemBuilder: (context, i) {
            final p = products[i];
            final String productId = p["p_id"].toString();
            final bool isSelected = selectedProductIds.contains(productId);


            int stockVal = int.tryParse(p["stock_quantity"].toString()) ?? 0;
            bool isLowStock = stockVal <= 5;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),

                side: isLowStock
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              child: ListTile(
                onLongPress: () {
                  setState(() {
                    isSelectionMode = true;
                    selectedProductIds.add(productId);
                  });
                },
                onTap: isSelectionMode ? () {
                  setState(() {
                    if (isSelected) {
                      selectedProductIds.remove(productId);
                      if (selectedProductIds.isEmpty) isSelectionMode = false;
                    } else {
                      selectedProductIds.add(productId);
                    }
                  });
                } : null,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelectionMode)
                      Checkbox(
                        value: isSelected,
                        activeColor: Colors.green[700],
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedProductIds.add(productId);
                            } else {
                              selectedProductIds.remove(productId);
                              if (selectedProductIds.isEmpty) isSelectionMode = false;
                            }
                          });
                        },
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        Uri.encodeFull(p["image_url"].toString()),
                        width: 60, height: 60, fit: BoxFit.cover,
                        headers: const {
                          "Access-Control-Allow-Origin": "*",
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ],
                ),
                title: TText(p["name"].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    Text("₹${p["price"]} | ", style: const TextStyle(color: Colors.green)),
                    const TText("Stock"),
                    Text(
                      ": $stockVal",
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.black,
                        fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),

                    if (isLowStock)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                      ),
                  ],
                ),
                trailing: isSelectionMode ? null : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                      onPressed: () => _showRestockDialog(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddProductPage(product: p)),
                        ).then((_) => fetchProducts());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteDialog(productId),
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

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TText("Confirm"),
        content: const TText("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TText("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(context); deleteProduct(id); },
            child: const TText("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TText("Bulk Delete"),
        content: TText("Delete ${selectedProductIds.length} products?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TText("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(context); deleteBulkProducts(); },
            child: const TText("Delete All", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

