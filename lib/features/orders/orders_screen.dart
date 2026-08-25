import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'My orders'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
        children: [
          Row(children: [
            GestureDetector(
                onTap: () => setState(() => tab = 0),
                child: AppTag(
                    label: 'Active',
                    variant:
                        tab == 0 ? TagVariant.accent : TagVariant.neutral)),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: () => setState(() => tab = 1),
                child: AppTag(
                    label: 'Past',
                    variant:
                        tab == 1 ? TagVariant.accent : TagVariant.neutral)),
          ]),
          const SizedBox(height: 14),
          if (tab == 0)
            _order('#PM-84291', 'Out for delivery', TagVariant.accentSoft,
                '3 items · AED 221 · Arrives today', 'Track',
                onTap: () => context.push(R.tracking), extraThumb: true)
          else ...[
            _order('#PM-83904', 'Delivered', TagVariant.accent2Soft,
                '1 item · AED 86 · Jul 28', 'Buy again'),
            const SizedBox(height: 12),
            _order('#PM-83411', 'Delivered', TagVariant.accent2Soft,
                '2 items · AED 154 · Jul 12', 'Buy again',
                extraThumb: true),
          ],
        ],
      ),
    );
  }

  Widget _order(String id, String status, TagVariant statusVariant, String meta,
      String actionLabel,
      {VoidCallback? onTap, bool extraThumb = false}) {
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
                child: Text(id,
                    style: AppText.body(size: 13, weight: FontWeight.w700))),
            AppTag(label: status, variant: statusVariant, dense: true),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            SizedBox(
                width: 52, height: 52, child: PhotoPlaceholder(radius: 14)),
            if (extraThumb) ...[
              const SizedBox(width: 8),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text('+1',
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
                child: Text(meta,
                    style:
                        AppText.body(size: 12.5, color: AppColors.neutral600))),
            GestureDetector(
              onTap: onTap,
              child: Text(actionLabel,
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
}
