import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenRepository {
  final SupabaseClient _client;
  DeviceTokenRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Registers the current device's FCM token against the signed-in user.
  /// Safe to call every time the app starts or the token refreshes.
  ///
  /// Uses a SECURITY DEFINER Postgres function (`register_device_token`)
  /// rather than a plain client-side upsert. Reason: the same physical
  /// device keeps the same FCM token across guest → sign-in → logout →
  /// sign-in-again cycles, but each of those is a *different* `user_id`.
  /// A plain upsert-by-token hits Postgres's UNIQUE(token) constraint and
  /// tries to UPDATE the row still owned by the previous user — which RLS
  /// correctly blocks (you can't silently take over someone else's row).
  /// The RPC deletes the stale row and re-inserts under the current user
  /// in one atomic, server-trusted step.
  Future<void> saveToken(String token) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.rpc('register_device_token', params: {
      'p_token': token,
      'p_platform': 'android',
    });
  }

  /// Removes this device's token — call on logout so a signed-out device
  /// stops receiving pushes meant for the account.
  Future<void> deleteToken(String token) async {
    await _client.from('device_tokens').delete().eq('token', token);
  }
}
