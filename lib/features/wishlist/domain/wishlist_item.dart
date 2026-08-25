class WishlistItem {
  final String id;
  final String productId;

  WishlistItem({required this.id, required this.productId});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
    );
  }
}
