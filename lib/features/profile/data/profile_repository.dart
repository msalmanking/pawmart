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

    final updates = <String, dynamic>{'id': userId};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;

    // upsert, not update: an account that signed in via Google/guest and
    // has never had a `profiles` row yet (no row-creation trigger has
    // fired for it) would otherwise have this UPDATE silently affect 0
    // rows — no error, but nothing saved either.
    await _client.from('profiles').upsert(updates);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
