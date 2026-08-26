import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order.dart';

class CheckoutRepository {
  final SupabaseClient _client;
  CheckoutRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Places a COD order from the current cart items.
  /// Client only sends product ids/qty — price is re-read from cart items
  /// (which themselves reference live product rows), not trusted blindly.
  Future<Order> placeOrder({
    required List<CartLineItem> items,
    Map<String, dynamic>? addressSnapshot,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');
    if (items.isEmpty) throw Exception('Cart is empty');

    final subtotal =
        items.fold<double>(0, (sum, i) => sum + (i.product.price * i.qty));
    const deliveryFee = 0.0; // free delivery for now
    final total = subtotal + deliveryFee;

    final orderRow = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'subtotal': subtotal,
          'delivery_fee': deliveryFee,
          'total': total,
          'payment_method': 'cod',
          'status': 'confirmed',
          'address_snapshot': addressSnapshot,
        })
        .select()
        .single();

    final order = Order.fromJson(orderRow);

    final itemRows = items
        .map((i) => {
              'order_id': order.id,
              'product_id': i.product.id,
              'qty': i.qty,
              'unit_price': i.product.price,
              'line_total': i.product.price * i.qty,
              'product_name': i.product.nameEn,
              'image_url': i.product.imageUrl,
            })
        .toList();

    await _client.from('order_items').insert(itemRows);

    await _client.from('order_events').insert({
      'order_id': order.id,
      'status': 'confirmed',
      'note': 'Order placed (Cash on Delivery)',
    });

    // Clear the cart.
    final cart = await _client
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (cart != null) {
      await _client
          .from('cart_items')
          .delete()
          .eq('cart_id', cart['id'] as String);
    }

    return order;
  }

  Future<List<Order>> fetchMyOrders() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('placed_at', ascending: false);

    return (data as List)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
