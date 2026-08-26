import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(Supabase.instance.client),
);

final notificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.fetchAll();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifAsync = ref.watch(notificationsProvider);
  return notifAsync.value?.where((n) => !n.isRead).length ?? 0;
});

Future<void> markNotificationRead(WidgetRef ref, String id) async {
  final repo = ref.read(notificationRepositoryProvider);
  await repo.markAsRead(id);
  ref.invalidate(notificationsProvider);
}

Future<void> markAllNotificationsRead(WidgetRef ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  await repo.markAllRead();
  ref.invalidate(notificationsProvider);
}
