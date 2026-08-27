import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../catalog/presentation/catalog_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/review.dart';
import 'reviews_providers.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  int filter = 0;

  @override
  void initState() {
    super.initState();
    // Force-refresh review state every time this screen opens, so a review
    // just written or an order just placed is reflected immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productId = ref.read(selectedProductIdProvider);
      if (productId != null) {
        ref.invalidate(canReviewProvider(productId));
        ref.invalidate(hasReviewedProvider(productId));
        ref.invalidate(productReviewsProvider(productId));
      }
    });
  }

  static const _filterLabels = ['All', 'With photos', '5 ★', 'Critical'];

  List<Review> _applyFilter(List<Review> reviews) {
    switch (filter) {
      case 1:
        return reviews.where((r) => r.imageUrls.isNotEmpty).toList();
      case 2:
        return reviews.where((r) => r.rating == 5).toList();
      case 3:
        return reviews.where((r) => r.rating <= 2).toList();
      default:
        return reviews;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productId = ref.watch(selectedProductIdProvider);

    if (productId == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: simpleAppBar(context, 'Reviews'),
        body: Center(
          child: Text('No product selected',
              style: AppText.body(size: 14, color: AppColors.neutral600)),
        ),
      );
    }

    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final summaryAsync = ref.watch(productRatingSummaryProvider(productId));
    final canReviewAsync = ref.watch(canReviewProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Reviews'),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(productReviewsProvider(productId));
          ref.invalidate(productRatingSummaryProvider(productId));
          ref.invalidate(canReviewProvider(productId));
          await ref.read(productReviewsProvider(productId).future);
        },
        child: reviewsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent)),
          error: (err, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text('Could not load reviews: $err',
                    style: AppText.body(size: 13, color: AppColors.neutral600)),
              ),
            ],
          ),
          data: (reviews) {
            final summary =
                summaryAsync.value ?? RatingSummary.fromReviews(reviews);
            final filtered = _applyFilter(reviews);

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 32),
              children: [
                _summaryHeader(summary),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (int i = 0; i < _filterLabels.length; i++) ...[
                        GestureDetector(
                          onTap: () => setState(() => filter = i),
                          child: AppTag(
                            label: _filterLabels[i],
                            dense: true,
                            variant: i == filter
                                ? TagVariant.accent
                                : TagVariant.neutral,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        reviews.isEmpty
                            ? 'No reviews yet — be the first to review this product.'
                            : 'No reviews match this filter.',
                        textAlign: TextAlign.center,
                        style:
                            AppText.body(size: 13, color: AppColors.neutral600),
                      ),
                    ),
                  )
                else
                  for (final review in filtered) ...[
                    _reviewCard(productId, review),
                    const SizedBox(height: 14),
                  ],
                const SizedBox(height: 6),
                canReviewAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (canReview) {
                    if (!canReview) {
                      final hasReviewedAsync =
                          ref.watch(hasReviewedProvider(productId));
                      return hasReviewedAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (hasReviewed) => Text(
                          hasReviewed
                              ? "You've already reviewed this product."
                              : 'Only customers with a delivered order for this product can write a review.',
                          textAlign: TextAlign.center,
                          style: AppText.body(
                              size: 11.5, color: AppColors.neutral500),
                        ),
                      );
                    }
                    return PillButton(
                      label: 'Write a review',
                      icon: LucideIcons.pencil,
                      variant: PillVariant.secondary,
                      height: 50,
                      onTap: () => _showWriteReviewSheet(context, productId),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryHeader(RatingSummary summary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(summary.total == 0 ? '—' : summary.average.toStringAsFixed(1),
                style: AppText.heading(size: 44)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => Icon(LucideIcons.star,
                    size: 14,
                    color: i < summary.average.round()
                        ? AppColors.accent
                        : AppColors.accent200),
              ),
            ),
            const SizedBox(height: 2),
            Text('${summary.total} reviews',
                style: AppText.body(size: 12, color: AppColors.neutral600)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  SizedBox(
                      width: 10,
                      child: Text('$star',
                          style:
                              AppText.body(size: 11, weight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: summary.fractionFor(i),
                        minHeight: 8,
                        backgroundColor: AppColors.neutral200,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(String productId, Review review) {
    final meta = [
      if (review.isVerified) 'Verified purchase',
      DateFormat('d MMM y').format(review.createdAt),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadow.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.accent2_200,
                  child: Text(review.initials,
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.accent2_800))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName,
                        style: AppText.body(size: 13, weight: FontWeight.w700)),
                    Text(meta,
                        style: AppText.body(
                            size: 11, color: AppColors.neutral600)),
                  ],
                ),
              ),
              Row(
                  children: List.generate(
                      5,
                      (i) => Icon(LucideIcons.star,
                          size: 12,
                          color: i < review.rating
                              ? AppColors.accent
                              : AppColors.accent200))),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.body,
              style: AppText.body(
                  size: 13, color: AppColors.neutral800, height: 1.55)),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (final url in review.imageUrls.take(3)) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(url,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const SizedBox(
                            width: 64,
                            height: 64,
                            child: PhotoPlaceholder(radius: 16))),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => markReviewHelpful(ref, productId, review),
            child: Row(children: [
              const Icon(LucideIcons.thumbsUp,
                  size: 14, color: AppColors.neutral600),
              const SizedBox(width: 6),
              Text('Helpful (${review.helpfulCount})',
                  style: AppText.body(size: 12, color: AppColors.neutral600)),
            ]),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context, String productId) {
    final bodyController = TextEditingController();
    int rating = 5;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Write a review', style: AppText.heading(size: 22)),
                    const SizedBox(height: 16),
                    Text('Your rating',
                        style: AppText.body(
                            size: 12, color: AppColors.neutral600)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setSheetState(() => rating = star),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(LucideIcons.star,
                                size: 30,
                                color: star <= rating
                                    ? AppColors.accent
                                    : AppColors.accent200),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text('Your review',
                        style: AppText.body(
                            size: 12, color: AppColors.neutral600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      maxLength: 600,
                      decoration: InputDecoration(
                        hintText:
                            'How did your pet like it? Anything worth knowing…',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your review is published after a quick moderation check.',
                      style:
                          AppText.body(size: 11, color: AppColors.neutral500),
                    ),
                    const SizedBox(height: 16),
                    PillButton(
                      label: submitting ? 'Submitting…' : 'Submit review',
                      height: 52,
                      enabled: !submitting,
                      onTap: () async {
                        final body = bodyController.text.trim();
                        if (body.isEmpty) return;
                        setSheetState(() => submitting = true);
                        try {
                          await submitProductReview(
                            ref,
                            productId: productId,
                            rating: rating,
                            body: body,
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Thanks! Your review has been posted.')),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => submitting = false);
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(content: Text('Could not submit: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
