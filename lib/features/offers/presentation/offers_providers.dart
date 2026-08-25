import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/offers_repository.dart';
import '../domain/banner_item.dart';
import '../domain/coupon.dart';

final offersRepositoryProvider = Provider<OffersRepository>(
  (ref) => OffersRepository(Supabase.instance.client),
);

final bannersProvider = FutureProvider<List<BannerItem>>((ref) async {
  final repo = ref.watch(offersRepositoryProvider);
  return repo.fetchBanners();
});

final couponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final repo = ref.watch(offersRepositoryProvider);
  return repo.fetchCoupons();
});
