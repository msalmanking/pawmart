import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(height: 280, width: double.infinity, child: PhotoPlaceholder(label: 'live map — courier route', radius: 0)),
                Positioned(
                  top: 24,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: AppColors.bg, shape: BoxShape.circle, boxShadow: AppShadow.sm),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: AppShadow.md,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arriving in 25 min', style: AppText.heading(size: 22)),
                      const SizedBox(height: 4),
                      Text('Order #PM-84291 · 3 items', style: AppText.body(size: 13, color: AppColors.neutral600)),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              FadeTransition(
                                opacity: _controller,
                                child: Column(children: [
                                  _step('Order confirmed', 'Today, 8:04 am', done: true),
                                  _step('Packed with care', 'Today, 9:12 am', done: true),
                                  _step('Out for delivery', 'Ahmed is 3 stops away', active: true),
                                  _step('Delivered', 'Est. 11:30 am', last: true),
                                ]),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: AppShadow.sm),
                                child: Row(children: [
                                  CircleAvatar(radius: 23, backgroundColor: AppColors.accent200, child: Text('A', style: AppText.body(size: 14, weight: FontWeight.w700, color: AppColors.accent800))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Ahmed — your courier', style: AppText.body(size: 14, weight: FontWeight.w700)),
                                        Text('PawMart delivery', style: AppText.body(size: 12, color: AppColors.neutral600)),
                                      ],
                                    ),
                                  ),
                                  _roundIcon(LucideIcons.phone, variant: PillVariant.secondary),
                                  const SizedBox(width: 8),
                                  _roundIcon(LucideIcons.messageCircle, variant: PillVariant.primary),
                                ]),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, {required PillVariant variant}) {
    final bg = variant == PillVariant.primary ? AppColors.accent : Colors.transparent;
    final fg = variant == PillVariant.primary ? AppColors.bg : AppColors.text;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: variant == PillVariant.secondary ? Border.all(color: AppColors.divider) : null),
      child: Icon(icon, size: 18, color: fg),
    );
  }

  Widget _step(String title, String subtitle, {bool done = false, bool active = false, bool last = false}) {
    final color = done ? AppColors.accent2 : (active ? AppColors.accent : AppColors.neutral300);
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
                  border: done || active ? null : Border.all(color: AppColors.neutral300, width: 2),
                ),
                child: done
                    ? const Icon(LucideIcons.check, size: 14, color: AppColors.bg)
                    : active
                        ? const Icon(LucideIcons.truck, size: 14, color: AppColors.bg)
                        : null,
              ),
              if (!last) Expanded(child: Container(width: 2, color: done ? AppColors.accent2 : AppColors.neutral300)),
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
                          color: last ? AppColors.neutral500 : (active ? AppColors.accent700 : AppColors.text))),
                  Text(subtitle, style: AppText.body(size: 12, color: last ? AppColors.neutral500 : AppColors.neutral600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
