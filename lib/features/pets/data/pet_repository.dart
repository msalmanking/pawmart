import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pet.dart';

class PetRepository {
  final SupabaseClient _client;
  PetRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Pet>> fetchPets() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('pets')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List)
        .map((json) => Pet.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPet({
    required String name,
    required String species,
    String? breed,
    DateTime? birthDate,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Login required');

    await _client.from('pets').insert({
      'user_id': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
    });
  }

  Future<void> updatePet(
    String petId, {
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (species != null) updates['species'] = species;
    if (breed != null) updates['breed'] = breed;
    if (birthDate != null) updates['birth_date'] = birthDate.toIso8601String();

    if (updates.isEmpty) return;
    await _client.from('pets').update(updates).eq('id', petId);
  }

  Future<void> deletePet(String petId) async {
    await _client.from('pets').delete().eq('id', petId);
  }
}
