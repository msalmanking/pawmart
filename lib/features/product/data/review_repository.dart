import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/review.dart';

class ReviewRepository {
  final SupabaseClient _client;
  ReviewRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Review>> fetchByProduct(String productId) async {
    final data = await _client
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .eq('status', 'approved')
        .order('created_at', ascending: false);
    return (data as List)
        .map((j) => Review.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<bool> hasOrdered(String productId) async {
    final userId = _userId;
    if (userId == null) return false;

    final orders = await _client
        .from('order_items')
        .select('order_id, orders!inner(user_id)')
        .eq('product_id', productId)
        .eq('orders.user_id', userId);
    return (orders as List).isNotEmpty;
  }

  Future<bool> hasReviewed(String productId) async {
    final userId = _userId;
    if (userId == null) return false;

    final existing = await _client
        .from('reviews')
        .select('id')
        .eq('product_id', productId)
        .eq('user_id', userId)
        .maybeSingle();
    return existing != null;
  }

  Future<bool> canReview(String productId) async {
    final results = await Future.wait([
      hasOrdered(productId),
      hasReviewed(productId),
    ]);
    final ordered = results[0];
    final reviewed = results[1];
    return ordered && !reviewed;
  }

  Future<void> submitReview(
      {required String productId, required int rating, String? body}) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');
    await _client.from('reviews').insert({
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'body': body,
      'is_verified': true,
    });
  }

  Future<void> markHelpful(String reviewId, int currentCount) async {
    await _client
        .from('reviews')
        .update({'helpful_count': currentCount + 1}).eq('id', reviewId);
  }
}
