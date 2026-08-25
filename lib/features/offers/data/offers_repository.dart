import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/banner_item.dart';
import '../domain/coupon.dart';

class OffersRepository {
  final SupabaseClient _client;
  OffersRepository(this._client);

  Future<List<BannerItem>> fetchBanners() async {
    final data = await _client.from('banners').select().order('sort_order');
    return (data as List)
        .map((json) => BannerItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Coupon>> fetchCoupons() async {
    final data = await _client
        .from('coupons')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List)
        .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
