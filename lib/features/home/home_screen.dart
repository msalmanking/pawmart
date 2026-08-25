import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../catalog/presentation/catalog_providers.dart';
import '../cart/presentation/cart_providers.dart';
import '../wishlist/presentation/wishlist_providers.dart';
import '../pets/presentation/pets_providers.dart';
import '../offers/presentation/offers_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _onNav(BuildContext context, WidgetRef ref, int i) {
    ref.read(bottomNavIndexProvider.notifier).state = i;
    switch (i) {
      case 0:
        break;
      case 1:
        context.push(R.categories);
        break;
      case 2:
        context.push(R.cart);
        break;
      case 3:
        context.push(R.wishlist);
        break;
      case 4:
        context.push(R.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(realPetsProvider);
    final petIndex = ref.watch(selectedPetIndexProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final bestsellersAsync = ref.watch(bestsellersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text('Deliver to',
                                  style: AppText.body(
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: AppColors.neutral600)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Marina Walk, Dubai',
                              style: AppText.body(
                                  size: 15, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(R.notifications),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: AppColors.surface, shape: BoxShape.circle),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(LucideIcons.bell, size: 20),
                            Positioned(
                              top: 9,
                              right: 11,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.surface, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => context.push(R.search),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.divider)),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search,
                            size: 18, color: AppColors.neutral600),
                        const SizedBox(width: 10),
                        Text('Search food, toys, litter…',
                            style: AppText.body(
                                size: 14, color: AppColors.neutral500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: petsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (pets) {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < pets.length; i++) ...[
                            GestureDetector(
                              onTap: () => ref
                                  .read(selectedPetIndexProvider.notifier)
                                  .state = i,
                              child: AppTag(
                                label: '${pets[i].name} · ${pets[i].species}',
                                icon: Icons.pets,
                                dense: false,
                                variant: i == petIndex
                                    ? TagVariant.accent
                                    : TagVariant.neutral,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          GestureDetector(
                            onTap: () => _showAddPetSheet(context, ref),
                            child: const AppTag(
                                label: '+ Add pet',
                                variant: TagVariant.outline),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final bannersAsync = ref.watch(bannersProvider);
                    return bannersAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (banners) {
                        if (banners.isEmpty) return const SizedBox.shrink();
                        final b = banners.first;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            height: 140,
                            color: AppColors.accent2,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 22,
                                        top: 14,
                                        right: 8,
                                        bottom: 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(b.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppText.heading(
                                                size: 19, color: AppColors.bg)),
                                        const SizedBox(height: 4),
                                        if (b.subtitle != null)
                                          Text(b.subtitle!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppText.body(
                                                  size: 12.5,
                                                  weight: FontWeight.w600,
                                                  color:
                                                      AppColors.accent2_100)),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => context.push(R.offers),
                                          child: Container(
                                            width: 104,
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: AppColors.bg,
                                                borderRadius:
                                                    BorderRadius.circular(999)),
                                            alignment: Alignment.center,
                                            child: Text('Shop now',
                                                style: AppText.body(
                                                    size: 12,
                                                    weight: FontWeight.w700,
                                                    color:
                                                        AppColors.accent2_800)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 128,
                                  child: b.imageUrl != null
                                      ? Image.network(
                                          b.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                              PhotoPlaceholder(
                                                  label: b.title, radius: 0),
                                        )
                                      : PhotoPlaceholder(
                                          label: b.title, radius: 0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: SectionHeading(
                  title: 'Shop by category',
                  actionLabel: 'See all',
                  onAction: () => context.push(R.categories),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _CategoryPuck(
                        icon: LucideIcons.bone,
                        label: 'Food',
                        bg: AppColors.accent100,
                        fg: AppColors.accent700),
                    _CategoryPuck(
                        icon: LucideIcons.gamepad2,
                        label: 'Toys',
                        bg: AppColors.accent2_100,
                        fg: AppColors.accent2_700),
                    _CategoryPuck(
                        icon: LucideIcons.bath,
                        label: 'Grooming',
                        bg: AppColors.accent100,
                        fg: AppColors.accent700),
                    _CategoryPuck(
                        icon: LucideIcons.stethoscope,
                        label: 'Health',
                        bg: AppColors.accent2_100,
                        fg: AppColors.accent2_700),
                    _CategoryPuck(
                        icon: LucideIcons.graduationCap,
                        label: 'Training',
                        bg: AppColors.accent100,
                        fg: AppColors.accent700),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: petsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (pets) {
                    final title = pets.isNotEmpty && petIndex < pets.length
                        ? 'Bestsellers for ${pets[petIndex].name}'
                        : 'Bestsellers for you';
                    return SectionHeading(
                      title: title,
                      actionLabel: 'See all',
                      onAction: () => context.push(R.listing),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 236,
                child: bestsellersAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.accent)),
                  error: (err, stack) => Center(
                    child: Text('Error: $err',
                        style: AppText.body(
                            size: 12, color: AppColors.neutral600)),
                  ),
                  data: (products) {
                    if (products.isEmpty) {
                      return Center(
                        child: Text('No products yet',
                            style: AppText.body(
                                size: 13, color: AppColors.neutral600)),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      children: products.map((p) {
                        return _ProductCard(
                          title: p.nameEn,
                          price: 'AED ${p.price.toStringAsFixed(0)}',
                          rating: '4.8 (New)',
                          photoLabel: p.nameEn,
                          imageUrl: p.imageUrl,
                          productId: p.id,
                          onTap: () {
                            ref.read(selectedProductIdProvider.notifier).state =
                                p.id;
                            context.push(R.productDetail);
                          },
                          onAdd: () async {
                            await addToCart(ref, p.id);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      bottomNavigationBar: PawBottomNav(
        currentIndex: ref.watch(bottomNavIndexProvider),
        cartCount: cartCount,
        onTap: (i) => _onNav(context, ref, i),
      ),
    );
  }
}

void _showAddPetSheet(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  String selectedSpecies = 'Dog';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Text('Add a pet', style: AppText.heading(size: 22)),
                  const SizedBox(height: 16),
                  Text('Name',
                      style:
                          AppText.body(size: 12, color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Buddy',
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
                  const SizedBox(height: 16),
                  Text('Species',
                      style:
                          AppText.body(size: 12, color: AppColors.neutral600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in ['Dog', 'Cat', 'Bird', 'Fish', 'Other'])
                        GestureDetector(
                          onTap: () => setState(() => selectedSpecies = s),
                          child: AppTag(
                            label: s,
                            variant: selectedSpecies == s
                                ? TagVariant.accent
                                : TagVariant.neutral,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                    label: 'Add pet',
                    height: 52,
                    onTap: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      await addPet(ref, name: name, species: selectedSpecies);
                      if (context.mounted) Navigator.pop(context);
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

class _CategoryPuck extends StatelessWidget {
  const _CategoryPuck(
      {required this.icon,
      required this.label,
      required this.bg,
      required this.fg});
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: fg),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppText.body(size: 12, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.rating,
    required this.photoLabel,
    required this.onTap,
    required this.onAdd,
    required this.productId,
    this.imageUrl,
  });
  final String title;
  final String price;
  final String rating;
  final String photoLabel;
  final String? imageUrl;
  final String productId;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 162,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  PhotoPlaceholder(
                                      label: photoLabel, radius: 24),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return PhotoPlaceholder(
                                    label: photoLabel, radius: 24);
                              },
                            ),
                          )
                        : PhotoPlaceholder(label: photoLabel, radius: 24),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final wishlistIdsAsync = ref.watch(wishlistIdsProvider);
                        final isLiked =
                            wishlistIdsAsync.value?.contains(productId) ??
                                false;
                        return GestureDetector(
                          onTap: () async {
                            await toggleWishlist(ref, productId, isLiked);
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: isLiked ? AppColors.accent : AppColors.bg,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(
                    size: 13, weight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.star, size: 13, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(rating,
                    style: AppText.body(size: 12, color: AppColors.neutral600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                    child: Text(price,
                        style:
                            AppText.body(size: 15, weight: FontWeight.w700))),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus,
                        size: 16, color: AppColors.bg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
