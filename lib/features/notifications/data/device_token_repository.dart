import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenRepository {
  final SupabaseClient _client;
  DeviceTokenRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Upserts the current device's FCM token against the signed-in user.
  /// Safe to call every time the app starts or the token refreshes.
  Future<void> saveToken(String token) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('device_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'token',
    );
  }

  /// Removes this device's token — call on logout so a signed-out device
  /// stops receiving pushes meant for the account.
  Future<void> deleteToken(String token) async {
    await _client.from('device_tokens').delete().eq('token', token);
  }
}
