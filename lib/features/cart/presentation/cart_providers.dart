import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(Supabase.instance.client),
);

final cartLineItemsProvider = FutureProvider<List<CartLineItem>>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.fetchCartItems();
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartLineItemsProvider);
  return cartAsync.value?.fold<int>(0, (sum, item) => sum + item.qty) ?? 0;
});

Future<void> addToCart(WidgetRef ref, String productId, {int qty = 1}) async {
  final repo = ref.read(cartRepositoryProvider);
  await repo.addToCart(productId, qty: qty);
  ref.invalidate(cartLineItemsProvider);
}

Future<void> updateCartQty(WidgetRef ref, String cartItemId, int qty) async {
  final repo = ref.read(cartRepositoryProvider);
  await repo.updateQty(cartItemId, qty);
  ref.invalidate(cartLineItemsProvider);
}

Future<void> removeCartItem(WidgetRef ref, String cartItemId) async {
  final repo = ref.read(cartRepositoryProvider);
  await repo.removeItem(cartItemId);
  ref.invalidate(cartLineItemsProvider);
}
