import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/orders_repository.dart';
import '../domain/order_summary.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(Supabase.instance.client),
);

final myOrdersListProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.fetchMyOrders();
});

final selectedOrderIdProvider = StateProvider<String?>((ref) => null);

final orderByIdProvider =
    FutureProvider.family<OrderSummary?, String>((ref, orderId) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.fetchOrderById(orderId);
});

final orderEventsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, orderId) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.fetchOrderEvents(orderId);
});
