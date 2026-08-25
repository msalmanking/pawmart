class Product {
  final String id;
  final String slug;
  final String nameEn;
  final String? descriptionEn;
  final double price;
  final double? compareAtPrice;
  final int stock;
  final String? imageUrl;
  final String? brand;
  final String? lifeStage;

  Product({
    required this.id,
    required this.slug,
    required this.nameEn,
    this.descriptionEn,
    required this.price,
    this.compareAtPrice,
    required this.stock,
    this.imageUrl,
    this.brand,
    this.lifeStage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameEn: json['name_en'] as String,
      descriptionEn: json['description_en'] as String?,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      brand: json['brand'] as String?,
      lifeStage: json['life_stage'] as String?,
    );
  }
}
