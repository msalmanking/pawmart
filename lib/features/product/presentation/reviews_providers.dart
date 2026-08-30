import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../paw_points/presentation/points_providers.dart';
import '../data/review_repository.dart';
import '../domain/review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(Supabase.instance.client);
});

/// Approved reviews for a given product.
final productReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.fetchForProduct(productId);
});

/// Rating summary (average, count, per-star distribution) derived from
/// the same approved reviews used above.
final productRatingSummaryProvider =
    FutureProvider.family<RatingSummary, String>((ref, productId) async {
  final reviews = await ref.watch(productReviewsProvider(productId).future);
  return RatingSummary.fromReviews(reviews);
});

/// Whether the signed-in user has already written a review for this product.
final hasReviewedProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.hasReviewed(productId);
});

/// Whether the signed-in user is eligible to write a review (delivered
/// order containing this product) and hasn't already reviewed it.
final canReviewProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final purchased = await repo.hasPurchased(productId);
  if (!purchased) return false;
  final already = await repo.hasReviewed(productId);
  return !already;
});

Future<void> submitProductReview(
  WidgetRef ref, {
  required String productId,
  required int rating,
  required String body,
}) async {
  final repo = ref.read(reviewRepositoryProvider);
  await repo.submitReview(productId: productId, rating: rating, body: body);
  ref.invalidate(productReviewsProvider(productId));
  ref.invalidate(productRatingSummaryProvider(productId));
  ref.invalidate(canReviewProvider(productId));
  ref.invalidate(hasReviewedProvider(productId));
  ref.invalidate(pointsHistoryProvider);
}

Future<void> markReviewHelpful(
    WidgetRef ref, String productId, Review review) async {
  final repo = ref.read(reviewRepositoryProvider);
  await repo.markHelpful(review.id, review.helpfulCount);
  ref.invalidate(productReviewsProvider(productId));
}
