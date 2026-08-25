import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../cart/presentation/cart_providers.dart';
import '../../../core/providers/app_providers.dart';
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
  int deliverySlot = 0;
  int payment = 0;
  bool usePoints = true;
  bool _placing = false;

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartItemsProvider.notifier).subtotal;
    final discount = usePoints ? 10.0 : 0.0;
    final total = subtotal - discount + (deliverySlot == 1 ? 15 : 0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Checkout'),
      body: ListView(
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
                          style:
                              AppText.body(size: 13, weight: FontWeight.w700))),
                  Text('Change',
                      style: AppText.body(
                          size: 12.5,
                          weight: FontWeight.w700,
                          color: AppColors.accent)),
                ]),
                const SizedBox(height: 6),
                Text(
                    'Home — Apt 1204, Marina Heights Tower, Marina Walk, Dubai',
                    style: AppText.body(
                        size: 13.5, color: AppColors.neutral800, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Delivery time',
              style: AppText.body(size: 13, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _slotCard(0, 'Tomorrow', '9 am – 1 pm · Free')),
            const SizedBox(width: 10),
            Expanded(child: _slotCard(1, 'Express', 'Today, 2 hrs · AED 15')),
          ]),
          const SizedBox(height: 18),
          Text('Payment',
              style: AppText.body(size: 13, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          _paymentTile(0, LucideIcons.creditCard, 'Visa ·· 4402'),
          const SizedBox(height: 8),
          _paymentTile(1, LucideIcons.smartphone, 'Apple Pay'),
          const SizedBox(height: 8),
          _paymentTile(2, LucideIcons.banknote, 'Cash on delivery'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.accent2_100,
                borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              const Icon(LucideIcons.medal,
                  size: 18, color: AppColors.accent2_700),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Use 200 Paw Points → save AED 10',
                      style: AppText.body(
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: AppColors.accent2_800))),
              Switch(
                value: usePoints,
                activeColor: AppColors.bg,
                activeTrackColor: AppColors.accent2,
                onChanged: (v) => setState(() => usePoints = v),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            24, 18, 24, 18 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
            color: AppColors.neutral100,
            border: Border(top: BorderSide(color: AppColors.divider))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Subtotal', 'AED ${subtotal.toStringAsFixed(0)}'),
            if (usePoints)
              _row(
                  'Paw Points discount', '− AED ${discount.toStringAsFixed(0)}',
                  valueColor: AppColors.accent2_700),
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
                enabled: !_placing,
                onTap: _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This runs from a button tap (a user event), which is the safe place to
  // mutate providers. Doing this inside another screen's initState/build —
  // which is what caused the crash — is not allowed by Riverpod because the
  // widget tree is still being built at that point.
  void _placeOrder() {
    if (_placing) return;
    setState(() => _placing = true);

    // Cart clear
    ref.invalidate(cartLineItemsProvider);

    context.pushReplacement(R.orderPlaced);
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

  Widget _slotCard(int index, String title, String subtitle) {
    final active = deliverySlot == index;
    return GestureDetector(
      onTap: () => setState(() => deliverySlot = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.accent100 : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: active ? AppColors.accent : AppColors.divider,
              width: active ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppText.body(size: 13, weight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: AppText.body(size: 11.5, color: AppColors.neutral700)),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(int index, IconData icon, String label) {
    final active = payment == index;
    return GestureDetector(
      onTap: () => setState(() => payment = index),
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
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: AppColors.accent100,
                          blurRadius: 0,
                          spreadRadius: 3.5)
                    ]
                  : null,
            ),
          ),
        ]),
      ),
    );
  }
}
