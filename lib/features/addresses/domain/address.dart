class Address {
  final String id;
  final String label;
  final String? building;
  final String? street;
  final String? area;
  final String? city;
  final String? emirate;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    this.building,
    this.street,
    this.area,
    this.city,
    this.emirate,
    required this.isDefault,
  });

  String get formatted {
    final parts = [building, street, area, city, emirate]
        .where((p) => p != null && p.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'No details added' : parts.join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      label: json['label'] as String,
      building: json['building'] as String?,
      street: json['street'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      emirate: json['emirate'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
