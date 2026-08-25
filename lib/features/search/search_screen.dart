import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../catalog/presentation/catalog_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      onPressed: () => context.pop()),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border:
                              Border.all(color: AppColors.accent, width: 1.5)),
                      child: Row(children: [
                        const Icon(LucideIcons.search,
                            size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            onChanged: _onChanged,
                            style:
                                AppText.body(size: 14, weight: FontWeight.w600),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: 'Search food, toys, litter…'),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                            child: const Icon(LucideIcons.x,
                                size: 16, color: AppColors.neutral500),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.trim().isEmpty
                  ? _buildEmptyState()
                  : resultsAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent)),
                      error: (err, _) => Center(
                        child: Text('Error: $err',
                            style: AppText.body(
                                size: 13, color: AppColors.neutral600)),
                      ),
                      data: (products) {
                        if (products.isEmpty) {
                          return Center(
                            child: Text('No products found for "$query"',
                                style: AppText.body(
                                    size: 14, color: AppColors.neutral600)),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.66,
                          ),
                          itemBuilder: (context, i) {
                            final p = products[i];
                            final hasDiscount = p.compareAtPrice != null &&
                                p.compareAtPrice! > p.price;
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(selectedProductIdProvider.notifier)
                                    .state = p.id;
                                context.push(R.productDetail);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1.25,
                                    child: p.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: Image.network(
                                              p.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  PhotoPlaceholder(
                                                      label: p.nameEn,
                                                      radius: 24),
                                            ),
                                          )
                                        : PhotoPlaceholder(
                                            label: p.nameEn, radius: 24),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(p.nameEn,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.body(
                                          size: 13,
                                          weight: FontWeight.w600,
                                          height: 1.3)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Text('AED ${p.price.toStringAsFixed(0)}',
                                        style: AppText.body(
                                            size: 14, weight: FontWeight.w700)),
                                    if (hasDiscount) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                          'AED ${p.compareAtPrice!.toStringAsFixed(0)}',
                                          style: AppText.body(
                                                  size: 11,
                                                  color: AppColors.neutral500)
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough)),
                                    ],
                                  ]),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
      children: [
        Text('Trending at PawMart',
            style: AppText.body(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.neutral700)),
        const SizedBox(height: 4),
        for (final t in [
          'Cooling mats for summer',
          'Slow-feeder bowls',
          'Reptile heat lamps',
          'Catnip toys'
        ])
          _trendingRow(t),
      ],
    );
  }

  Widget _trendingRow(String label) => GestureDetector(
        onTap: () {
          _controller.text = label;
          ref.read(searchQueryProvider.notifier).state = label;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Row(children: [
            const Icon(LucideIcons.trendingUp,
                size: 16, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppText.body(size: 14))),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: AppColors.neutral500),
          ]),
        ),
      );
}
