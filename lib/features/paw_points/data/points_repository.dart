import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/points_entry.dart';

class PointsRepository {
  final SupabaseClient _client;
  PointsRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<PointsEntry>> fetchHistory() async {
    final userId = _userId;
    if (userId == null) {
      print('POINTS: no user id, returning empty');
      return [];
    }

    final data = await _client
        .from('points_ledger')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    print('POINTS: fetched ${(data as List).length} rows for user $userId');

    return data
        .map((json) => PointsEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> redeem({required int cost, required String reason}) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');

    final result = await _client.from('points_ledger').insert({
      'user_id': userId,
      'delta': -cost,
      'reason': reason,
    }).select();

    print('POINTS: redeem insert result = $result');
  }
}
