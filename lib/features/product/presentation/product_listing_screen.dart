import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class ProductListingScreen extends ConsumerWidget {
  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final categoryId = ref.watch(selectedCategoryIdProvider);
    final categoryName = ref.watch(selectedCategoryNameProvider);
    final filter = ref.watch(productFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop()),
        title: Text(categoryName, style: AppText.heading(size: 21)),
        actions: [
          IconButton(
              icon: const Icon(LucideIcons.search),
              onPressed: () => context.push(R.search)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () => showFiltersSheet(context, ref),
                  child: AppTag(
                      label: 'Filters',
                      icon: LucideIcons.slidersHorizontal,
                      variant: TagVariant.accent,
                      dense: true),
                ),
              ],
            ),
          ),
          Expanded(
            child: categoryId == null
                ? Center(
                    child: Text('Select a category to view products',
                        style: AppText.body(
                            size: 13, color: AppColors.neutral600)),
                  )
                : Consumer(
                    builder: (context, ref, _) {
                      final productsAsync =
                          ref.watch(productsByCategoryProvider(categoryId));
                      return productsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent)),
                        error: (err, _) => Center(
                          child: Text('Error: $err',
                              style: AppText.body(
                                  size: 12, color: AppColors.neutral600)),
                        ),
                        data: (allProducts) {
                          final products =
                              applyProductFilter(allProducts, filter);
                          if (products.isEmpty) {
                            return Center(
                              child: Text('No products match your filters',
                                  style: AppText.body(
                                      size: 13, color: AppColors.neutral600)),
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
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: p.imageUrl != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
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
                                                    label: p.nameEn,
                                                    radius: 24),
                                          ),
                                          if (hasDiscount)
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: AppTag(
                                                  label:
                                                      '-${(100 - (p.price / p.compareAtPrice! * 100)).round()}%',
                                                  variant: TagVariant.accent,
                                                  dense: true),
                                            ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Consumer(
                                              builder: (context, ref, _) {
                                                final wishlistIdsAsync = ref
                                                    .watch(wishlistIdsProvider);
                                                final isLiked = wishlistIdsAsync
                                                        .value
                                                        ?.contains(p.id) ??
                                                    false;
                                                return GestureDetector(
                                                  onTap: () async {
                                                    await toggleWishlist(
                                                        ref, p.id, isLiked);
                                                  },
                                                  child: Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 20,
                                                    color: isLiked
                                                        ? AppColors.accent
                                                        : AppColors.bg,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
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
                                      const Icon(LucideIcons.star,
                                          size: 13, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text('New',
                                          style: AppText.body(
                                              size: 12,
                                              color: AppColors.neutral600)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 6,
                                            children: [
                                              Text(
                                                  'AED ${p.price.toStringAsFixed(0)}',
                                                  style: AppText.body(
                                                      size: 14,
                                                      weight: FontWeight.w700)),
                                              if (hasDiscount)
                                                Text(
                                                    'AED ${p.compareAtPrice!.toStringAsFixed(0)}',
                                                    style: AppText.body(
                                                            size: 11,
                                                            color: AppColors
                                                                .neutral500)
                                                        .copyWith(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await addToCart(ref, p.id);
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                                color: AppColors.accent,
                                                shape: BoxShape.circle),
                                            child: const Icon(LucideIcons.plus,
                                                size: 15, color: AppColors.bg),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: PawBottomNav(
        currentIndex: 1,
        cartCount: cartCount,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
          if (i == 0) context.go(R.home);
          if (i == 2) context.push(R.cart);
          if (i == 3) context.push(R.wishlist);
          if (i == 4) context.push(R.profile);
        },
      ),
    );
  }
}

void showFiltersSheet(BuildContext context, WidgetRef parentRef) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _FiltersSheet(),
  );
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  static const _sortOptions = [
    'Recommended',
    'Price: low → high',
    'Top rated',
    'Newest'
  ];
  static const _priceOptions = ['Under 50', '50–150', '150–300', '300+'];
  static const _lifeStageOptions = ['puppy', 'adult', 'senior'];
  static const _lifeStageLabels = ['Puppy', 'Adult', 'Senior'];
  static const _brandOptions = [
    'Happy Bowl',
    'MeadowMeal',
    'Wagly',
    'FinFresh'
  ];

  late ProductFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(productFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categoryId = ref.watch(selectedCategoryIdProvider);
    final matchCount = categoryId == null
        ? 0
        : ref.watch(productsByCategoryProvider(categoryId)).maybeWhen(
              data: (products) => applyProductFilter(products, _draft).length,
              orElse: () => 0,
            );

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(26, 14, 26, 40),
            children: [
              Center(
                child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(3))),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                    child: Text('Filters', style: AppText.heading(size: 22))),
                GestureDetector(
                  onTap: () => setState(() => _draft = const ProductFilter()),
                  child: Text('Reset',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ]),
              const SizedBox(height: 18),
              _group(
                  'Sort by',
                  _sortOptions,
                  _draft.sortIndex,
                  (i) =>
                      setState(() => _draft = _draft.copyWith(sortIndex: i))),
              const SizedBox(height: 18),
              _group(
                  'Price',
                  _priceOptions,
                  _draft.priceIndex,
                  (i) =>
                      setState(() => _draft = _draft.copyWith(priceIndex: i))),
              const SizedBox(height: 18),
              _labeledGroup(
                'Life stage',
                _lifeStageLabels,
                _lifeStageOptions,
                _draft.lifeStage,
                (value) => setState(
                    () => _draft = _draft.copyWith(lifeStage: () => value)),
                activeVariant: TagVariant.accent2Soft,
              ),
              const SizedBox(height: 18),
              _labeledGroup(
                'Brand',
                _brandOptions,
                _brandOptions,
                _draft.brand,
                (value) => setState(
                    () => _draft = _draft.copyWith(brand: () => value)),
              ),
              const SizedBox(height: 26),
              PillButton(
                label: 'Show $matchCount products',
                height: 52,
                onTap: () {
                  ref.read(productFilterProvider.notifier).state = _draft;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _group(
      String label, List<String> options, int active, ValueChanged<int> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.body(size: 13, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < options.length; i++)
              GestureDetector(
                onTap: () => onTap(i),
                child: AppTag(
                    label: options[i],
                    variant:
                        i == active ? TagVariant.accent : TagVariant.neutral,
                    dense: true),
              ),
          ],
        ),
      ],
    );
  }

  Widget _labeledGroup(
    String label,
    List<String> displayLabels,
    List<String> values,
    String? activeValue,
    ValueChanged<String?> onTap, {
    TagVariant activeVariant = TagVariant.accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.body(size: 13, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < values.length; i++)
              GestureDetector(
                onTap: () => onTap(activeValue == values[i] ? null : values[i]),
                child: AppTag(
                    label: displayLabels[i],
                    variant: activeValue == values[i]
                        ? activeVariant
                        : TagVariant.neutral,
                    dense: true),
              ),
          ],
        ),
      ],
    );
  }
}
