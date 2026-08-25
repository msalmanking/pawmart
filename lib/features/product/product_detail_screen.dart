import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../catalog/presentation/catalog_providers.dart';
import '../cart/presentation/cart_providers.dart';
import '../wishlist/presentation/wishlist_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import 'domain/product.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final productId = ref.watch(selectedProductIdProvider);

    if (productId == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(),
        body: Center(
          child: Text('No product selected',
              style: AppText.body(size: 14, color: AppColors.neutral600)),
        ),
      );
    }

    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: productAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent)),
          error: (err, _) => Center(
            child: Text('Error: $err',
                style: AppText.body(size: 13, color: AppColors.neutral600)),
          ),
          data: (product) {
            if (product == null) {
              return Center(
                child: Text('Product not found',
                    style: AppText.body(size: 14, color: AppColors.neutral600)),
              );
            }
            return _buildContent(context, product, cartCount);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Product product, int cartCount) {
    final hasDiscount = product.compareAtPrice != null &&
        product.compareAtPrice! > product.price;
    final discountPercent = hasDiscount
        ? (100 - (product.price / product.compareAtPrice! * 100)).round()
        : 0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(48)),
                    child: SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => PhotoPlaceholder(
                                  label: product.nameEn, radius: 0),
                            )
                          : PhotoPlaceholder(label: product.nameEn, radius: 0),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 20,
                    child: _circleIcon(LucideIcons.arrowLeft,
                        onTap: () => context.pop()),
                  ),
                  Positioned(
                    top: 24,
                    right: 20,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final wishlistIdsAsync = ref.watch(wishlistIdsProvider);
                        final isLiked =
                            wishlistIdsAsync.value?.contains(product.id) ??
                                false;
                        return _circleIcon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? AppColors.accent : AppColors.text,
                            onTap: () async {
                          await toggleWishlist(ref, product.id, isLiked);
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.stock <= 0)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: AppTag(
                            label: 'Out of stock',
                            variant: TagVariant.neutral,
                            dense: true),
                      ),
                    Text(product.nameEn, style: AppText.heading(size: 23)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Text('AED ${product.price.toStringAsFixed(0)}',
                          style: AppText.heading(size: 26)),
                      if (hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                            'AED ${product.compareAtPrice!.toStringAsFixed(0)}',
                            style: AppText.body(
                                    size: 14, color: AppColors.neutral500)
                                .copyWith(
                                    decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 10),
                        AppTag(
                            label: 'Save $discountPercent%',
                            variant: TagVariant.accentSoft,
                            dense: true),
                      ],
                    ]),
                    const SizedBox(height: 18),
                    if (product.descriptionEn != null)
                      Text(
                        product.descriptionEn!,
                        style: AppText.body(
                            size: 13.5,
                            color: AppColors.neutral700,
                            height: 1.6),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _perk(
                              LucideIcons.truck,
                              'Free delivery tomorrow',
                              AppColors.accent2_100,
                              AppColors.accent2_700,
                              AppColors.accent2_800),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _perk(
                              LucideIcons.package,
                              '${product.stock} in stock',
                              AppColors.accent100,
                              AppColors.accent700,
                              AppColors.accent800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
              color: AppColors.neutral100,
              border: Border(top: BorderSide(color: AppColors.divider))),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 48,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider),
                    color: AppColors.bg),
                child: Row(children: [
                  GestureDetector(
                      onTap: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                      child: const Icon(LucideIcons.minus, size: 16)),
                  SizedBox(
                      width: 30,
                      child: Text('$qty',
                          textAlign: TextAlign.center,
                          style:
                              AppText.body(size: 15, weight: FontWeight.w700))),
                  GestureDetector(
                      onTap: () => setState(() => qty++),
                      child: const Icon(LucideIcons.plus, size: 16)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: product.stock > 0 ? 'Add to cart' : 'Out of stock',
                  icon: LucideIcons.shoppingCart,
                  height: 52,
                  enabled: product.stock > 0,
                  onTap: () async {
                    await addToCart(ref, product.id, qty: qty);
                    if (context.mounted) context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon,
      {required VoidCallback onTap, Color color = AppColors.text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: AppColors.bg,
            shape: BoxShape.circle,
            boxShadow: AppShadow.sm),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _perk(
      IconData icon, String label, Color bg, Color iconColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 17, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: AppText.body(
                    size: 11.5, weight: FontWeight.w600, color: textColor))),
      ]),
    );
  }
}
