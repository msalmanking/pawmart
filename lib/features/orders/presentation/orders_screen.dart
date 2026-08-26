import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/order_summary.dart';
import '../presentation/orders_providers.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'My orders'),
      body: ordersAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: AppText.body(size: 13, color: AppColors.neutral600)),
        ),
        data: (allOrders) {
          final active = allOrders.where((o) => o.isActive).toList();
          final past = allOrders.where((o) => !o.isActive).toList();
          final shown = tab == 0 ? active : past;

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            children: [
              Row(children: [
                GestureDetector(
                    onTap: () => setState(() => tab = 0),
                    child: AppTag(
                        label: 'Active (${active.length})',
                        variant:
                            tab == 0 ? TagVariant.accent : TagVariant.neutral)),
                const SizedBox(width: 8),
                GestureDetector(
                    onTap: () => setState(() => tab = 1),
                    child: AppTag(
                        label: 'Past (${past.length})',
                        variant:
                            tab == 1 ? TagVariant.accent : TagVariant.neutral)),
              ]),
              const SizedBox(height: 14),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                        tab == 0 ? 'No active orders' : 'No past orders yet',
                        style: AppText.body(
                            size: 13, color: AppColors.neutral600)),
                  ),
                )
              else
                for (final order in shown) ...[
                  _order(order),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }

  Widget _order(OrderSummary order) {
    final statusLabel = _statusLabel(order.status);
    final statusVariant =
        order.isActive ? TagVariant.accentSoft : TagVariant.accent2Soft;
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.qty);
    final dateStr = DateFormat('MMM d').format(order.placedAt);
    final extraThumb = order.items.length > 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadow.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text('#${order.orderNumber}',
                    style: AppText.body(size: 13, weight: FontWeight.w700))),
            AppTag(label: statusLabel, variant: statusVariant, dense: true),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            SizedBox(
              width: 52,
              height: 52,
              child:
                  order.items.isNotEmpty && order.items.first.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(order.items.first.imageUrl!,
                              fit: BoxFit.cover),
                        )
                      : PhotoPlaceholder(radius: 14),
            ),
            if (extraThumb) ...[
              const SizedBox(width: 8),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text('+${order.items.length - 1}',
                    style: AppText.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.neutral600)),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} · AED ${order.total.toStringAsFixed(0)} · $dateStr',
                    style:
                        AppText.body(size: 12.5, color: AppColors.neutral600))),
            GestureDetector(
              onTap: () {
                ref.read(selectedOrderIdProvider.notifier).state = order.id;
                context.push(R.tracking);
              },
              child: Text(order.isActive ? 'Track' : 'View',
                  style: AppText.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.accent)),
            ),
          ]),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'packed':
        return 'Packed';
      case 'out_for_delivery':
        return 'Out for delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
