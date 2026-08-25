class PetCategory {
  final String id;
  final String slug;
  final String nameEn;
  final String? icon;
  final String type; // 'pet' or 'need'

  PetCategory({
    required this.id,
    required this.slug,
    required this.nameEn,
    this.icon,
    required this.type,
  });

  factory PetCategory.fromJson(Map<String, dynamic> json) {
    return PetCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameEn: json['name_en'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
    );
  }
}