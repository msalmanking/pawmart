import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/category.dart';

class CategoryRepository {
  final SupabaseClient _client;
  CategoryRepository(this._client);

  Future<List<PetCategory>> fetchByType(String type) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('type', type)
        .order('sort_order');

    return (data as List)
        .map((json) => PetCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}