import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../cart/domain/cart_item.dart';
import '../data/checkout_repository.dart';
import '../domain/order.dart';
import '../../orders/presentation/orders_providers.dart';
import '../../paw_points/presentation/points_providers.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(Supabase.instance.client),
);

final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(checkoutRepositoryProvider);
  return repo.fetchMyOrders();
});

Future<Order> placeOrder(WidgetRef ref, List<CartLineItem> items,
    {Map<String, dynamic>? addressSnapshot}) async {
  final repo = ref.read(checkoutRepositoryProvider);
  final order =
      await repo.placeOrder(items: items, addressSnapshot: addressSnapshot);
  ref.invalidate(cartLineItemsProvider);
  ref.invalidate(myOrdersListProvider);
  ref.invalidate(pointsHistoryProvider);
  return order;
}
