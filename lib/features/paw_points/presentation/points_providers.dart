import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/points_repository.dart';
import '../domain/points_entry.dart';

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(Supabase.instance.client),
);

final pointsHistoryProvider = FutureProvider<List<PointsEntry>>((ref) async {
  final repo = ref.watch(pointsRepositoryProvider);
  return repo.fetchHistory();
});

final pointsBalanceProvider = Provider<int>((ref) {
  final historyAsync = ref.watch(pointsHistoryProvider);
  return historyAsync.value?.fold<int>(0, (sum, e) => sum + e.delta) ?? 0;
});

Future<void> redeemPoints(WidgetRef ref,
    {required int cost, required String reason}) async {
  final repo = ref.read(pointsRepositoryProvider);
  await repo.redeem(cost: cost, reason: reason);
  ref.invalidate(pointsHistoryProvider);
}
