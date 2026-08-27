class Review {
  final String id;
  final String productId;
  final int rating;
  final String body;
  final List<String> imageUrls;
  final bool isVerified;
  final int helpfulCount;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.rating,
    required this.body,
    this.imageUrls = const [],
    required this.isVerified,
    required this.helpfulCount,
    required this.createdAt,
  });

  String get authorName =>
      isVerified ? 'Verified Customer' : 'PawMart Customer';
  String get initials => authorName.isNotEmpty ? authorName[0] : 'P';

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      rating: json['rating'] as int,
      body: (json['body'] as String?) ?? '',
      imageUrls:
          (json['image_urls'] as List?)?.map((e) => e as String).toList() ?? [],
      isVerified: json['is_verified'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class RatingSummary {
  final int total;
  final double average;
  final Map<int, int> starCounts;

  RatingSummary(
      {required this.total, required this.average, required this.starCounts});

  factory RatingSummary.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty)
      return RatingSummary(total: 0, average: 0, starCounts: {});
    final counts = <int, int>{};
    for (final r in reviews) {
      counts[r.rating] = (counts[r.rating] ?? 0) + 1;
    }
    final avg =
        reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
    return RatingSummary(
        total: reviews.length, average: avg, starCounts: counts);
  }

  double fractionFor(int i) {
    if (total == 0) return 0;
    final star = 5 - i;
    return (starCounts[star] ?? 0) / total;
  }
}
