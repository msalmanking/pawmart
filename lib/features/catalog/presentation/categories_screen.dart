import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './catalog_providers.dart';
import '../../cart/presentation/cart_providers.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openListing(BuildContext context, WidgetRef ref, PetCategory cat) {
    ref.read(selectedCategoryIdProvider.notifier).state = cat.id;
    ref.read(selectedCategoryNameProvider.notifier).state = cat.nameEn;
    context.push(R.listing);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final petsAsync = ref.watch(petCategoriesProvider);
    final needsAsync = ref.watch(needCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
          children: [
            Text('Shop by pet', style: AppText.heading(size: 26)),
            const SizedBox(height: 14),
            petsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent)),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Error loading pets: $err',
                    style: AppText.body(size: 12, color: AppColors.neutral600)),
              ),
              data: (pets) {
                if (pets.isEmpty) {
                  return Text('No pet categories yet',
                      style:
                          AppText.body(size: 13, color: AppColors.neutral600));
                }
                return GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.98,
                  children: [
                    for (final p in pets)
                      GestureDetector(
                        onTap: () => _openListing(context, ref, p),
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.accent100,
                              borderRadius: BorderRadius.circular(28)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.icon ?? '🐾',
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 8),
                              Text(p.nameEn,
                                  style: AppText.body(
                                      size: 13, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            Text('Shop by need', style: AppText.heading(size: 26)),
            const SizedBox(height: 10),
            needsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent)),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Error loading needs: $err',
                    style: AppText.body(size: 12, color: AppColors.neutral600)),
              ),
              data: (needs) {
                if (needs.isEmpty) {
                  return Text('No categories yet',
                      style:
                          AppText.body(size: 13, color: AppColors.neutral600));
                }
                return Column(
                  children: [
                    for (final n in needs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _openListing(context, ref, n),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              children: [
                                Text(n.icon ?? '🐾',
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 14),
                                Expanded(
                                    child: Text(n.nameEn,
                                        style: AppText.body(
                                            size: 14,
                                            weight: FontWeight.w600))),
                                const Icon(LucideIcons.chevronRight,
                                    size: 18, color: AppColors.neutral500),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
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
