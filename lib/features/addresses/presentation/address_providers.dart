import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/address_repository.dart';
import '../domain/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(Supabase.instance.client),
);

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final repo = ref.watch(addressRepositoryProvider);
  return repo.fetchAll();
});

Future<void> addAddress(
  WidgetRef ref, {
  required String label,
  String? building,
  String? street,
  String? area,
  String? city,
  String? emirate,
  bool isDefault = false,
}) async {
  final repo = ref.read(addressRepositoryProvider);
  await repo.addAddress(
    label: label,
    building: building,
    street: street,
    area: area,
    city: city,
    emirate: emirate,
    isDefault: isDefault,
  );
  ref.invalidate(addressesProvider);
}

Future<void> deleteAddress(WidgetRef ref, String id) async {
  final repo = ref.read(addressRepositoryProvider);
  await repo.deleteAddress(id);
  ref.invalidate(addressesProvider);
}

Future<void> setDefaultAddress(WidgetRef ref, String id) async {
  final repo = ref.read(addressRepositoryProvider);
  await repo.setDefault(id);
  ref.invalidate(addressesProvider);
}
