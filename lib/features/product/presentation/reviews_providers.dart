import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/review_repository.dart';
import '../domain/review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(Supabase.instance.client),
);

final productReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.fetchByProduct(productId);
});

final productRatingSummaryProvider =
    FutureProvider.family<RatingSummary, String>((ref, productId) async {
  final reviews = await ref.watch(productReviewsProvider(productId).future);
  return RatingSummary.fromReviews(reviews);
});

final canReviewProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.canReview(productId);
});

Future<void> submitProductReview(WidgetRef ref,
    {required String productId, required int rating, String? body}) async {
  final repo = ref.read(reviewRepositoryProvider);
  await repo.submitReview(productId: productId, rating: rating, body: body);
  ref.invalidate(productReviewsProvider(productId));
  ref.invalidate(productRatingSummaryProvider(productId));
  ref.invalidate(canReviewProvider(productId));
}

Future<void> markReviewHelpful(
    WidgetRef ref, String productId, Review review) async {
  final repo = ref.read(reviewRepositoryProvider);
  await repo.markHelpful(review.id, review.helpfulCount);
  ref.invalidate(productReviewsProvider(productId));
}

final hasReviewedProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.hasReviewed(productId);
});
