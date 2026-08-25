import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../presentation/wishlist_providers.dart';

import '../../catalog/presentation/catalog_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final wishlistAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Wishlist', style: AppText.heading(size: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: wishlistAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => Text('${items.length} saved',
                    style: AppText.body(size: 13, color: AppColors.neutral600)),
              ),
            ),
          ),
        ],
      ),
      body: wishlistAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: AppText.body(size: 13, color: AppColors.neutral600)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.heart,
                      size: 48, color: AppColors.neutral400),
                  const SizedBox(height: 12),
                  Text('Your wishlist is empty',
                      style:
                          AppText.body(size: 14, color: AppColors.neutral600)),
                  const SizedBox(height: 4),
                  Text(
                      'Save products to your wishlist by tapping the heart icon',
                      style:
                          AppText.body(size: 12, color: AppColors.neutral500)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.66),
            itemBuilder: (context, i) {
              final p = items[i];
              final hasDiscount =
                  p.compareAtPrice != null && p.compareAtPrice! > p.price;
              final outOfStock = p.stock <= 0;

              return Opacity(
                opacity: outOfStock ? 0.65 : 1,
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedProductIdProvider.notifier).state = p.id;
                    context.push(R.productDetail);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.25,
                        child: Stack(children: [
                          Positioned.fill(
                            child: p.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      p.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                          PhotoPlaceholder(
                                              label: p.nameEn, radius: 24),
                                    ),
                                  )
                                : PhotoPlaceholder(label: p.nameEn, radius: 24),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () async {
                                await toggleWishlist(ref, p.id, true);
                              },
                              child: const Icon(
                                Icons.favorite,
                                size: 20,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          if (hasDiscount)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: AppTag(
                                  label:
                                      '-${(100 - (p.price / p.compareAtPrice! * 100)).round()}%',
                                  variant: TagVariant.accentSoft,
                                  dense: true),
                            ),
                        ]),
                      ),
                      const SizedBox(height: 7),
                      Text(p.nameEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                              size: 13, weight: FontWeight.w600, height: 1.3)),
                      const SizedBox(height: 2),
                      if (outOfStock)
                        Text('Out of stock',
                            style: AppText.body(
                                size: 12.5,
                                weight: FontWeight.w700,
                                color: AppColors.accent700))
                      else
                        Row(children: [
                          Text('AED ${p.price.toStringAsFixed(0)}',
                              style: AppText.body(
                                  size: 14, weight: FontWeight.w700)),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text('AED ${p.compareAtPrice!.toStringAsFixed(0)}',
                                style: AppText.body(
                                        size: 11, color: AppColors.neutral500)
                                    .copyWith(
                                        decoration:
                                            TextDecoration.lineThrough)),
                          ],
                        ]),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: PillButton(
                          label: outOfStock ? 'Notify me' : 'Move to cart',
                          height: 36,
                          fontSize: 12.5,
                          variant: outOfStock
                              ? PillVariant.secondary
                              : PillVariant.primary,
                          onTap: () async {
                            if (!outOfStock) {
                              await addToCart(ref, p.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: PawBottomNav(
        currentIndex: 3,
        cartCount: cartCount,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
          if (i == 0) context.go(R.home);
          if (i == 1) context.push(R.categories);
          if (i == 2) context.push(R.cart);
          if (i == 4) context.push(R.profile);
        },
      ),
    );
  }
}
