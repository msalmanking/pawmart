import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class _Notif {
  const _Notif(
      this.icon, this.iconBg, this.iconFg, this.title, this.body, this.time,
      {this.unread = false, this.highlight = false});
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final bool highlight;
}

const _notifs = [
  _Notif(
      LucideIcons.truck,
      AppColors.accent200,
      AppColors.accent700,
      'Your order is out for delivery',
      'Ahmed is on the way with #PM-84291. Arriving ~11:30 am.',
      '12 min ago',
      unread: true,
      highlight: true),
  _Notif(
      LucideIcons.percent,
      AppColors.accent2_100,
      AppColors.accent2_700,
      'Puppy Week is live',
      'Up to 40% off food & toys for Buddy. Ends Sunday.',
      '2 hrs ago',
      unread: true),
  _Notif(
      LucideIcons.medal,
      AppColors.accent2_100,
      AppColors.accent2_700,
      'You earned 23 Paw Points',
      'From order #PM-84291. Balance: 340 points.',
      '3 hrs ago',
      unread: true),
  _Notif(
      LucideIcons.package,
      AppColors.neutral100,
      AppColors.neutral600,
      'Order #PM-83904 delivered',
      'Rate your MeadowMeal cans and earn 5 points.',
      'Jul 28'),
  _Notif(
      LucideIcons.heart,
      AppColors.neutral100,
      AppColors.neutral600,
      'Back in stock',
      'CloudNest Ortho Dog Bed L from your wishlist is available.',
      'Jul 26'),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.of(context).maybePop()),
        title: Text('Notifications', style: AppText.heading(size: 21)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
                child: Text('Mark all read',
                    style: AppText.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: AppColors.accent))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
        children: [
          Row(children: [
            for (int i = 0; i < 3; i++) ...[
              GestureDetector(
                onTap: () => setState(() => filter = i),
                child: AppTag(
                    label: ['All', 'Orders', 'Offers'][i],
                    dense: true,
                    variant:
                        i == filter ? TagVariant.accent : TagVariant.neutral),
              ),
              const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 12),
          for (final n in _notifs) _tile(n),
        ],
      ),
    );
  }

  Widget _tile(_Notif n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding:
          EdgeInsets.symmetric(vertical: 10, horizontal: n.highlight ? 10 : 4),
      decoration: n.highlight
          ? BoxDecoration(
              color: AppColors.accent100,
              borderRadius: BorderRadius.circular(22))
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Opacity(
        opacity: n.unread ? 1 : 0.7,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: n.iconBg, shape: BoxShape.circle),
                child: Icon(n.icon, size: 18, color: n.iconFg)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(n.title,
                      style: AppText.body(size: 13.5, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(n.body,
                      style: AppText.body(
                          size: 12.5,
                          color: AppColors.neutral700,
                          height: 1.45)),
                  const SizedBox(height: 2),
                  Text(n.time,
                      style:
                          AppText.body(size: 11, color: AppColors.neutral500)),
                ],
              ),
            ),
            if (n.unread)
              Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle))),
          ],
        ),
      ),
    );
  }
}
