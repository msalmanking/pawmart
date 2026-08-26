import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/app_notification.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationsProvider);

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
              child: GestureDetector(
                onTap: () async => markAllNotificationsRead(ref),
                child: Text('Mark all read',
                    style: AppText.body(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: AppColors.accent)),
              ),
            ),
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: AppText.body(size: 13, color: AppColors.neutral600)),
        ),
        data: (allNotifs) {
          final filtered = filter == 0
              ? allNotifs
              : filter == 1
                  ? allNotifs.where((n) => n.type == 'order').toList()
                  : allNotifs.where((n) => n.type == 'offer').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            children: [
              Row(children: [
                for (int i = 0; i < 3; i++) ...[
                  GestureDetector(
                    onTap: () => setState(() => filter = i),
                    child: AppTag(
                        label: ['All', 'Orders', 'Offers'][i],
                        dense: true,
                        variant: i == filter
                            ? TagVariant.accent
                            : TagVariant.neutral),
                  ),
                  const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No notifications here',
                        style: AppText.body(
                            size: 13, color: AppColors.neutral600)),
                  ),
                )
              else
                for (final n in filtered) _tile(n),
            ],
          );
        },
      ),
    );
  }

  (IconData, Color, Color) _iconFor(String type) {
    switch (type) {
      case 'order':
        return (LucideIcons.truck, AppColors.accent200, AppColors.accent700);
      case 'offer':
        return (
          LucideIcons.percent,
          AppColors.accent2_100,
          AppColors.accent2_700
        );
      default:
        return (LucideIcons.bell, AppColors.neutral100, AppColors.neutral600);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(dt);
  }

  Widget _tile(AppNotification n) {
    final (icon, iconBg, iconFg) = _iconFor(n.type);
    final unread = !n.isRead;

    return GestureDetector(
      onTap: () {
        if (unread) markNotificationRead(ref, n.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            EdgeInsets.symmetric(vertical: 10, horizontal: unread ? 10 : 4),
        decoration: unread
            ? BoxDecoration(
                color: AppColors.accent100,
                borderRadius: BorderRadius.circular(22))
            : const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider))),
        child: Opacity(
          opacity: unread ? 1 : 0.7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: iconFg)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(n.title,
                        style:
                            AppText.body(size: 13.5, weight: FontWeight.w700)),
                    if (n.body != null) ...[
                      const SizedBox(height: 2),
                      Text(n.body!,
                          style: AppText.body(
                              size: 12.5,
                              color: AppColors.neutral700,
                              height: 1.45)),
                    ],
                    const SizedBox(height: 2),
                    Text(_timeAgo(n.createdAt),
                        style: AppText.body(
                            size: 11, color: AppColors.neutral500)),
                  ],
                ),
              ),
              if (unread)
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
      ),
    );
  }
}
