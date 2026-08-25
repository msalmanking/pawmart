import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/product.dart';

class ProductRepository {
  final SupabaseClient _client;
  ProductRepository(this._client);

  Future<List<Product>> fetchProducts({int limit = 10}) async {
    final data = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> fetchByCategory(String categoryId) async {
    final data = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .eq('category_id', categoryId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Product?> fetchById(String productId) async {
    final data = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .maybeSingle();

    if (data == null) return null;
    return Product.fromJson(data);
  }

  Future<List<Product>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final data = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .ilike('name_en', '%$query%')
        .limit(20);

    return (data as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
