import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/address.dart';

class AddressRepository {
  final SupabaseClient _client;
  AddressRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Address>> fetchAll() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at');

    return (data as List)
        .map((json) => Address.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAddress({
    required String label,
    String? building,
    String? street,
    String? area,
    String? city,
    String? emirate,
    bool isDefault = false,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');

    if (isDefault) {
      await _client
          .from('addresses')
          .update({'is_default': false}).eq('user_id', userId);
    }

    await _client.from('addresses').insert({
      'user_id': userId,
      'label': label,
      'building': building,
      'street': street,
      'area': area,
      'city': city,
      'emirate': emirate,
      'is_default': isDefault,
    });
  }

  Future<void> deleteAddress(String id) async {
    await _client.from('addresses').delete().eq('id', id);
  }

  Future<void> setDefault(String id) async {
    final userId = _userId;
    if (userId == null) return;
    await _client
        .from('addresses')
        .update({'is_default': false}).eq('user_id', userId);
    await _client.from('addresses').update({'is_default': true}).eq('id', id);
  }
}
