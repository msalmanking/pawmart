import '../../product/domain/product.dart';

class CartLineItem {
  final String id;
  final int qty;
  final Product product;

  CartLineItem({
    required this.id,
    required this.qty,
    required this.product,
  });

  factory CartLineItem.fromJson(Map<String, dynamic> json) {
    return CartLineItem(
      id: json['id'] as String,
      qty: json['qty'] as int,
      product: Product.fromJson(json['products'] as Map<String, dynamic>),
    );
  }

  double get lineTotal => product.price * qty;
}
