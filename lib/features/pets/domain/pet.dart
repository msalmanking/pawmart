class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final String? avatarUrl;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.avatarUrl,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
