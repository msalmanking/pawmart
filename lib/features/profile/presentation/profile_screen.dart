import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './profile_providers.dart';
import '../../pets/presentation/pets_providers.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../paw_points/presentation/points_providers.dart';
import '../../notifications/presentation/notification_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(realPetsProvider);
    final petIndex = ref.watch(selectedPetIndexProvider);
    final points = ref.watch(pointsBalanceProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
          children: [
            profileAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent)),
              ),
              error: (err, _) => Text('Error loading profile: $err',
                  style: AppText.body(size: 12, color: AppColors.neutral600)),
              data: (profile) {
                final displayName =
                    (profile?.fullName?.trim().isNotEmpty ?? false)
                        ? profile!.fullName!
                        : 'Guest User';
                final displayPhone = profile?.phone ?? 'No phone linked';
                final initial =
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

                return Row(children: [
                  CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.accent2_200,
                      child: Text(initial,
                          style: AppText.heading(
                              size: 22, color: AppColors.accent2_800))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: AppText.heading(size: 20)),
                        Text(displayPhone,
                            style: AppText.body(
                                size: 13, color: AppColors.neutral600)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditProfileSheet(
                        context, ref, profile?.fullName ?? ''),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.divider)),
                      child: const Icon(LucideIcons.pencil, size: 16),
                    ),
                  ),
                ]);
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push(R.pawPoints),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(28)),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.accent400, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.medal,
                        size: 22, color: AppColors.bg),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$points Paw Points',
                            style:
                                AppText.heading(size: 17, color: AppColors.bg)),
                        Text('160 more to a free grooming kit',
                            style: AppText.body(
                                size: 12, color: AppColors.accent200)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      size: 18, color: AppColors.bg),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
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
                              variant: i == petIndex
                                  ? TagVariant.accent
                                  : TagVariant.neutral),
                        ),
                        const SizedBox(width: 8),
                      ],
                      GestureDetector(
                        onTap: () => _showAddPetSheet(context, ref),
                        child: const AppTag(
                            label: '+ Add pet', variant: TagVariant.outline),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _menuTile(LucideIcons.package, 'My orders',
                onTap: () => context.push(R.orders)),
            _menuTile(LucideIcons.heart, 'Wishlist',
                onTap: () => context.push(R.wishlist)),
            _menuTile(LucideIcons.mapPin, 'Addresses',
                onTap: () => context.push(R.addresses)),
            _menuTile(LucideIcons.creditCard, 'Payment methods', onTap: () {}),
            _menuTile(LucideIcons.bell, 'Notifications',
                trailingTag: unreadCount > 0 ? '$unreadCount new' : null,
                onTap: () => context.push(R.notifications)),
            _menuTile(LucideIcons.messageCircle, 'Help & live chat',
                onTap: () => context.push(R.liveChat)),
            _menuTile(LucideIcons.logOut, 'Log out', onTap: () async {
              await signOutUser(ref);
              if (context.mounted) context.go(R.signIn);
            }, muted: true, showChevron: false),
          ],
        ),
      ),
      bottomNavigationBar: PawBottomNav(
        currentIndex: 4,
        cartCount: cartCount,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
          if (i == 0) context.go(R.home);
          if (i == 1) context.push(R.categories);
          if (i == 2) context.push(R.cart);
          if (i == 3) context.push(R.wishlist);
        },
      ),
    );
  }

  Widget _menuTile(IconData icon, String label,
      {required VoidCallback onTap,
      String? trailingTag,
      bool muted = false,
      bool showChevron = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: showChevron
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)))
            : null,
        child: Row(children: [
          Icon(icon,
              size: 19,
              color: muted ? AppColors.neutral600 : AppColors.accent700),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: AppText.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: muted ? AppColors.neutral600 : AppColors.text))),
          if (trailingTag != null) ...[
            AppTag(
                label: trailingTag,
                variant: TagVariant.accentSoft,
                dense: true),
            const SizedBox(width: 8)
          ],
          if (showChevron)
            const Icon(LucideIcons.chevronRight,
                size: 17, color: AppColors.neutral500),
        ]),
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

void _showEditProfileSheet(
    BuildContext context, WidgetRef ref, String currentName) {
  final nameController = TextEditingController(text: currentName);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              Text('Edit profile', style: AppText.heading(size: 22)),
              const SizedBox(height: 16),
              Text('Full name',
                  style: AppText.body(size: 12, color: AppColors.neutral600)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Layla Hassan',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              PillButton(
                label: 'Save',
                height: 52,
                onTap: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  await updateProfile(ref, fullName: name);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
