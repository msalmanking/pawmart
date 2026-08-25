import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../presentation/cart_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/cart_item.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartLineItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop()),
        title: Text('My cart', style: AppText.heading(size: 21)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: cartAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => Text('${items.length} items',
                    style: AppText.body(size: 13, color: AppColors.neutral600)),
              ),
            ),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: AppText.body(size: 13, color: AppColors.neutral600)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.shoppingCart,
                    size: 56, color: AppColors.neutral400),
                const SizedBox(height: 12),
                Text('Your cart is empty',
                    style: AppText.body(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.neutral600)),
              ]),
            );
          }
          final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineTotal);
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            children: [
              for (final item in items) ...[
                _CartTile(
                  item: item,
                  onInc: () => updateCartQty(ref, item.id, item.qty + 1),
                  onDec: () => updateCartQty(ref, item.id, item.qty - 1),
                  onRemove: () => removeCartItem(ref, item.id),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: AppColors.accent2_100,
                    borderRadius: BorderRadius.circular(999)),
                child: Row(children: [
                  const Icon(LucideIcons.medal,
                      size: 18, color: AppColors.accent2_700),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          "You'll earn ${(subtotal / 10).floor()} Paw Points with this order",
                          style: AppText.body(
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: AppColors.accent2_800))),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider)),
                child: Row(children: [
                  const Icon(LucideIcons.ticket,
                      size: 17, color: AppColors.neutral600),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text('Promo code',
                          style: AppText.body(
                              size: 14, color: AppColors.neutral500))),
                  Text('Apply',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.accent)),
                ]),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: cartAsync.maybeWhen(
        data: (items) {
          if (items.isEmpty) return null;
          final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineTotal);
          return Container(
            padding: EdgeInsets.fromLTRB(
                24, 18, 24, 18 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
                color: AppColors.neutral100,
                border: Border(top: BorderSide(color: AppColors.divider))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _summaryRow('Subtotal', 'AED ${subtotal.toStringAsFixed(0)}'),
                _summaryRow('Delivery', 'Free',
                    valueColor: AppColors.accent2_700),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(color: AppColors.divider, height: 1)),
                _summaryRow('Total', 'AED ${subtotal.toStringAsFixed(0)}',
                    bold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                      label: 'Checkout · AED ${subtotal.toStringAsFixed(0)}',
                      height: 54,
                      onTap: () => context.push(R.checkout)),
                ),
              ],
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppText.body(
                  size: bold ? 16 : 13.5,
                  weight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? AppColors.text : AppColors.neutral700)),
          Text(value,
              style: AppText.body(
                  size: bold ? 16 : 13.5,
                  weight: FontWeight.w700,
                  color: valueColor ?? AppColors.text)),
        ],
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile(
      {required this.item,
      required this.onInc,
      required this.onDec,
      required this.onRemove});
  final CartLineItem item;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadow.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: item.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => PhotoPlaceholder(
                          label: item.product.nameEn, radius: 20),
                    ),
                  )
                : PhotoPlaceholder(label: item.product.nameEn, radius: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.product.nameEn,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                        size: 13.5, weight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 3),
                Text('AED ${item.product.price.toStringAsFixed(0)}',
                    style: AppText.body(size: 14.5, weight: FontWeight.w700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                  onTap: onRemove,
                  child: const Icon(LucideIcons.trash2,
                      size: 16, color: AppColors.neutral500)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                      onTap: onDec,
                      child: const Icon(LucideIcons.minus, size: 13)),
                  SizedBox(
                      width: 24,
                      child: Text('${item.qty}',
                          textAlign: TextAlign.center,
                          style:
                              AppText.body(size: 13, weight: FontWeight.w700))),
                  GestureDetector(
                      onTap: onInc,
                      child: const Icon(LucideIcons.plus, size: 13)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
