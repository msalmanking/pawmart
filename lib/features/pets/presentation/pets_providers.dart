import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/pet_repository.dart';
import '../domain/pet.dart';

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepository(Supabase.instance.client),
);

final realPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final repo = ref.watch(petRepositoryProvider);
  return repo.fetchPets();
});

Future<void> addPet(WidgetRef ref,
    {required String name, required String species, String? breed}) async {
  final repo = ref.read(petRepositoryProvider);
  await repo.addPet(name: name, species: species, breed: breed);
  ref.invalidate(realPetsProvider);
}

Future<void> deletePet(WidgetRef ref, String petId) async {
  final repo = ref.read(petRepositoryProvider);
  await repo.deletePet(petId);
  ref.invalidate(realPetsProvider);
}
