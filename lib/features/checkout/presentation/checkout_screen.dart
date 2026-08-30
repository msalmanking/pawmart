import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../cart/presentation/cart_providers.dart';
import '../../addresses/presentation/address_providers.dart';
import '../presentation/checkout_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int payment = 2; // Cash on delivery is the only working method for now
  bool _placing = false;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartLineItemsProvider);
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Checkout'),
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
              child: Text('Your cart is empty',
                  style: AppText.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.neutral600)),
            );
          }

          final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineTotal);
          const deliveryFee = 0.0;
          final total = subtotal + deliveryFee;

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppShadow.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(LucideIcons.mapPin,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('Deliver to',
                              style: AppText.body(
                                  size: 13, weight: FontWeight.w700))),
                      GestureDetector(
                        onTap: () => context.push(R.addresses),
                        child: Text('Change',
                            style: AppText.body(
                                size: 12.5,
                                weight: FontWeight.w700,
                                color: AppColors.accent)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    addressesAsync.when(
                      loading: () => Text('Loading address…',
                          style: AppText.body(
                              size: 13, color: AppColors.neutral600)),
                      error: (_, __) => Text('Could not load address',
                          style: AppText.body(
                              size: 13, color: AppColors.neutral600)),
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          return GestureDetector(
                            onTap: () => context.push(R.addresses),
                            child: Text('No address added — tap to add one',
                                style: AppText.body(
                                    size: 13.5,
                                    weight: FontWeight.w600,
                                    color: AppColors.accent)),
                          );
                        }
                        final addr = addresses.first;
                        return Text('${addr.label} — ${addr.formatted}',
                            style: AppText.body(
                                size: 13.5,
                                color: AppColors.neutral800,
                                height: 1.5));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Payment',
                  style: AppText.body(size: 13, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              _paymentTile(
                  0, LucideIcons.creditCard, 'Visa ·· 4402 (coming soon)',
                  enabled: false),
              const SizedBox(height: 8),
              _paymentTile(1, LucideIcons.smartphone, 'Apple Pay (coming soon)',
                  enabled: false),
              const SizedBox(height: 8),
              _paymentTile(2, LucideIcons.banknote, 'Cash on delivery',
                  enabled: true),
              const SizedBox(height: 18),
              Text('Order summary',
                  style: AppText.body(size: 13, weight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(
                        child: Text('${item.product.nameEn} × ${item.qty}',
                            style: AppText.body(
                                size: 13, color: AppColors.neutral700))),
                    Text('AED ${item.lineTotal.toStringAsFixed(0)}',
                        style: AppText.body(size: 13, weight: FontWeight.w600)),
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
          const deliveryFee = 0.0;
          final total = subtotal + deliveryFee;
          final hasAddress = addressesAsync.valueOrNull?.isNotEmpty ?? false;

          return Container(
            padding: EdgeInsets.fromLTRB(
                24, 18, 24, 18 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
                color: AppColors.neutral100,
                border: Border(top: BorderSide(color: AppColors.divider))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _row('Subtotal', 'AED ${subtotal.toStringAsFixed(0)}'),
                _row('Delivery', 'Free', valueColor: AppColors.accent2_700),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(color: AppColors.divider, height: 1)),
                _row('Total', 'AED ${total.toStringAsFixed(0)}', bold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: _placing ? 'Placing order…' : 'Place order',
                    icon: LucideIcons.lock,
                    height: 54,
                    enabled: !_placing && payment == 2 && hasAddress,
                    onTap: () => _placeOrder(items),
                  ),
                ),
                if (!hasAddress)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => context.push(R.addresses),
                      child: Text('Add a delivery address to continue',
                          style: AppText.body(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: AppColors.accent)),
                    ),
                  )
                else if (payment != 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Only Cash on delivery is available right now',
                        style: AppText.body(
                            size: 11.5, color: AppColors.neutral600)),
                  ),
              ],
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Future<void> _placeOrder(List items) async {
    if (_placing) return;

    final addresses = await ref.read(addressesProvider.future);
    if (addresses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please add a delivery address before placing your order.'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _placing = true);

    try {
      final a = addresses.first;
      final snapshot = {
        'label': a.label,
        'formatted': a.formatted,
      };

      await placeOrder(ref, items.cast(), addressSnapshot: snapshot);

      if (mounted) context.pushReplacement(R.orderPlaced);
    } catch (e) {
      if (mounted) {
        setState(() => _placing = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _row(String label, String value,
          {bool bold = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
        ]),
      );

  Widget _paymentTile(int index, IconData icon, String label,
      {required bool enabled}) {
    final active = payment == index;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? () => setState(() => payment = index) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: active ? AppColors.accent100 : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: active ? AppColors.accent : AppColors.divider,
                width: active ? 2 : 1),
          ),
          child: Row(children: [
            Icon(icon,
                size: 18,
                color: active ? AppColors.accent700 : AppColors.neutral700),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: AppText.body(size: 13.5, weight: FontWeight.w600))),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.accent : Colors.transparent,
                border: active
                    ? null
                    : Border.all(color: AppColors.divider, width: 1.5),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
