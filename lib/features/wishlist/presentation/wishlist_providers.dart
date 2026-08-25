import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/wishlist_repository.dart';
import '../../product/domain/product.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(Supabase.instance.client),
);

final wishlistProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(wishlistRepositoryProvider);
  return repo.fetchWishlistProducts();
});

final wishlistIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(wishlistRepositoryProvider);
  return repo.fetchWishlistProductIds();
});

Future<void> toggleWishlist(
    WidgetRef ref, String productId, bool isInWishlist) async {
  final repo = ref.read(wishlistRepositoryProvider);
  if (isInWishlist) {
    await repo.removeFromWishlist(productId);
  } else {
    await repo.addToWishlist(productId);
  }
  ref.invalidate(wishlistIdsProvider);
  ref.invalidate(wishlistProductsProvider);
}
