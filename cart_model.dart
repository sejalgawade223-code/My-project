class CartItem {
  final int cartId;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.cartId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: int.parse(json['cart_id'].toString()),
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      quantity: int.parse(json['quantity'].toString()),
    );
  }
}
