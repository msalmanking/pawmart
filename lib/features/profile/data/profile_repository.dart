import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<UserProfile?> fetchProfile() async {
    final userId = _userId;
    if (userId == null) return null;

    final data =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;

    if (updates.isEmpty) return;
    await _client.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
