import 'package:supabase_flutter/supabase_flutter.dart';
import '../../product/domain/product.dart';

class WishlistRepository {
  final SupabaseClient _client;
  WishlistRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Product>> fetchWishlistProducts() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('wishlist_items')
        .select('product_id, products(*)')
        .eq('user_id', userId);

    return (data as List)
        .where((row) => row['products'] != null)
        .map((row) => Product.fromJson(row['products'] as Map<String, dynamic>))
        .toList();
  }

  Future<Set<String>> fetchWishlistProductIds() async {
    final userId = _userId;
    if (userId == null) return {};

    final data = await _client
        .from('wishlist_items')
        .select('product_id')
        .eq('user_id', userId);

    return (data as List).map((row) => row['product_id'] as String).toSet();
  }

  Future<void> addToWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('Login required to add to wishlist');
    }
    await _client.from('wishlist_items').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFromWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    await _client
        .from('wishlist_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
