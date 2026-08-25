import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/cart_item.dart';

class CartRepository {
  final SupabaseClient _client;
  CartRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Ensures a cart row exists for the current user, returns its id.
  Future<String> _ensureCart() async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('Login required');
    }

    final existing = await _client
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final created = await _client
        .from('carts')
        .insert({'user_id': userId})
        .select('id')
        .single();

    return created['id'] as String;
  }

  Future<List<CartLineItem>> fetchCartItems() async {
    final userId = _userId;
    if (userId == null) return [];

    final cart = await _client
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (cart == null) return [];

    final data = await _client
        .from('cart_items')
        .select('id, qty, products(*)')
        .eq('cart_id', cart['id'] as String)
        .order('added_at');

    return (data as List)
        .where((row) => row['products'] != null)
        .map((row) => CartLineItem.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToCart(String productId, {int qty = 1}) async {
    final cartId = await _ensureCart();

    final existing = await _client
        .from('cart_items')
        .select('id, qty')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('cart_items')
          .update({'qty': (existing['qty'] as int) + qty}).eq(
              'id', existing['id'] as String);
    } else {
      await _client.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': productId,
        'qty': qty,
      });
    }
  }

  Future<void> updateQty(String cartItemId, int qty) async {
    if (qty <= 0) {
      await removeItem(cartItemId);
      return;
    }
    await _client.from('cart_items').update({'qty': qty}).eq('id', cartItemId);
  }

  Future<void> removeItem(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) return;
    final cart = await _client
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (cart == null) return;
    await _client
        .from('cart_items')
        .delete()
        .eq('cart_id', cart['id'] as String);
  }
}
