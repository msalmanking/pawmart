import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/order_summary.dart';

class OrdersRepository {
  final SupabaseClient _client;
  OrdersRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<OrderSummary>> fetchMyOrders() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('placed_at', ascending: false);

    return (data as List)
        .map((json) => OrderSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<OrderSummary?> fetchOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();
    if (data == null) return null;
    return OrderSummary.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> fetchOrderEvents(String orderId) async {
    final data = await _client
        .from('order_events')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return (data as List).cast<Map<String, dynamic>>();
  }
}
