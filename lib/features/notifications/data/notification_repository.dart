import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/app_notification.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<AppNotification>> fetchAll() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _client
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()}).eq('id', id);
  }

  Future<void> markAllRead() async {
    final userId = _userId;
    if (userId == null) return;
    await _client
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }
}
