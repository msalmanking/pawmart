import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import 'orders_providers.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = ref.watch(selectedOrderIdProvider);

    if (orderId == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(),
        body: Center(
          child: Text('No order selected',
              style: AppText.body(size: 14, color: AppColors.neutral600)),
        ),
      );
    }

    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final eventsAsync = ref.watch(orderEventsProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: orderAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent)),
          error: (err, _) => Center(
            child: Text('Error: $err',
                style: AppText.body(size: 13, color: AppColors.neutral600)),
          ),
          data: (order) {
            if (order == null) {
              return Center(
                child: Text('Order not found',
                    style: AppText.body(size: 14, color: AppColors.neutral600)),
              );
            }
            final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.qty);

            return Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: PhotoPlaceholder(
                            label: 'delivery route', radius: 0)),
                    Positioned(
                      top: 24,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: AppColors.bg,
                              shape: BoxShape.circle,
                              boxShadow: AppShadow.sm),
                          child: const Icon(LucideIcons.arrowLeft, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40)),
                        boxShadow: AppShadow.md,
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_statusHeadline(order.status),
                              style: AppText.heading(size: 22)),
                          const SizedBox(height: 4),
                          Text('Order #${order.orderNumber} · $itemCount items',
                              style: AppText.body(
                                  size: 13, color: AppColors.neutral600)),
                          const SizedBox(height: 18),
                          Expanded(
                            child: SingleChildScrollView(
                              child: eventsAsync.when(
                                loading: () => const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.accent)),
                                error: (err, _) => Text('Error: $err',
                                    style: AppText.body(
                                        size: 12, color: AppColors.neutral600)),
                                data: (events) {
                                  final steps =
                                      _buildSteps(order.status, events);
                                  return FadeTransition(
                                    opacity: _controller,
                                    child: Column(children: steps),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusHeadline(String status) {
    switch (status) {
      case 'pending':
        return 'Order received';
      case 'confirmed':
        return 'Order confirmed';
      case 'packed':
        return 'Being packed';
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

  List<Widget> _buildSteps(
      String currentStatus, List<Map<String, dynamic>> events) {
    const order = ['confirmed', 'packed', 'out_for_delivery', 'delivered'];
    const labels = {
      'confirmed': 'Order confirmed',
      'packed': 'Packed with care',
      'out_for_delivery': 'Out for delivery',
      'delivered': 'Delivered',
    };

    final currentIndex = order.indexOf(currentStatus);

    return List.generate(order.length, (i) {
      final stepStatus = order[i];
      final event = events.where((e) => e['status'] == stepStatus).toList();
      final done =
          i < currentIndex || (i == currentIndex && stepStatus == 'delivered');
      final active = i == currentIndex && stepStatus != 'delivered';
      final subtitle = event.isNotEmpty
          ? (event.first['note'] as String? ?? '')
          : (active ? 'In progress' : 'Pending');

      return _step(labels[stepStatus]!, subtitle,
          done: done, active: active, last: i == order.length - 1);
    });
  }

  Widget _step(String title, String subtitle,
      {bool done = false, bool active = false, bool last = false}) {
    final color = done
        ? AppColors.accent2
        : (active ? AppColors.accent : AppColors.neutral300);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done || active ? color : AppColors.bg,
                  shape: BoxShape.circle,
                  border: done || active
                      ? null
                      : Border.all(color: AppColors.neutral300, width: 2),
                ),
                child: done
                    ? const Icon(LucideIcons.check,
                        size: 14, color: AppColors.bg)
                    : active
                        ? const Icon(LucideIcons.truck,
                            size: 14, color: AppColors.bg)
                        : null,
              ),
              if (!last)
                Expanded(
                    child: Container(
                        width: 2,
                        color:
                            done ? AppColors.accent2 : AppColors.neutral300)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.body(
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: last
                              ? AppColors.neutral500
                              : (active
                                  ? AppColors.accent700
                                  : AppColors.text))),
                  Text(subtitle,
                      style: AppText.body(
                          size: 12,
                          color: last
                              ? AppColors.neutral500
                              : AppColors.neutral600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
