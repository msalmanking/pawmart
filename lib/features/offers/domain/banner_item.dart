class BannerItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? deepLink;

  BannerItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.deepLink,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String?,
      deepLink: json['deep_link'] as String?,
    );
  }
}
