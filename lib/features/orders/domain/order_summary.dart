class OrderSummary {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final DateTime placedAt;
  final List<OrderLineItem> items;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.placedAt,
    required this.items,
  });

  bool get isActive => status != 'delivered' && status != 'cancelled';

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['order_items'] as List? ?? [])
        .map((i) => OrderLineItem.fromJson(i as Map<String, dynamic>))
        .toList();

    return OrderSummary(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      placedAt: DateTime.parse(json['placed_at'] as String),
      items: itemsList,
    );
  }
}

class OrderLineItem {
  final String productName;
  final int qty;
  final String? imageUrl;

  OrderLineItem({required this.productName, required this.qty, this.imageUrl});

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productName: json['product_name'] as String,
      qty: json['qty'] as int,
      imageUrl: json['image_url'] as String?,
    );
  }
}
