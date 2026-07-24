
class Product {
  final int pId;
  final String name;
  final String brand;
  final String type;
  final String desc;
  final String? descriptionMr;
  final String? descriptionHi;
  final String image;
  final String price;
  final String stock;

  Product({
    required this.pId,
    required this.name,
    required this.brand,
    required this.type,
    required this.desc,
    this.descriptionMr,
    this.descriptionHi,
    required this.image,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pId: int.parse((json['p_id'] ?? json['id']).toString()),
      name: json['name'] ?? 'Unknown',
      brand: json['brand'] ?? 'N/A',
      type: json['type'] ?? '',

      desc: json['desc'] ?? '',

      descriptionMr: json['description_mr']?.toString(),
      descriptionHi: json['description_hi']?.toString(),
      image: (json['image'] ?? '').toString().trim(),
      price: json['price']?.toString() ?? '0',
  stock: json['stock_quantity']?.toString() ?? '0',
    );
  }
}