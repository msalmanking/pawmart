import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class PawPointsScreen extends ConsumerWidget {
  const PawPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pawPointsProvider);
    const target = 500;
    final progress = (points / target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              decoration: const BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.vertical(bottom: Radius.circular(48))),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(icon: const Icon(LucideIcons.arrowLeft, color: AppColors.bg), onPressed: () => Navigator.of(context).maybePop()),
                    Text('Paw Points', style: AppText.heading(size: 21, color: AppColors.bg)),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: AppColors.accent400, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.medal, size: 36, color: AppColors.bg),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: points),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Text('$value', style: AppText.heading(size: 42, color: AppColors.bg)),
                  ),
                  Text('points · worth AED ${(points / 20).toStringAsFixed(0)}', style: AppText.body(size: 13, weight: FontWeight.w600, color: AppColors.accent200)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: AppColors.accent700,
                        valueColor: const AlwaysStoppedAnimation(AppColors.bg),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${target - points} points to your next reward — free grooming kit',
                      textAlign: TextAlign.center, style: AppText.body(size: 12, weight: FontWeight.w600, color: AppColors.accent200)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to earn', style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.neutral700)),
                  const SizedBox(height: 10),
                  _pill(LucideIcons.shoppingBag, '1 point per AED 10 spent'),
                  const SizedBox(height: 8),
                  _pill(LucideIcons.star, '5 points per product review'),
                  const SizedBox(height: 8),
                  _pill(LucideIcons.users, '50 points per friend referred'),
                  const SizedBox(height: 22),
                  Text('Redeem', style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.neutral700)),
                  const SizedBox(height: 10),
                  _redeem(LucideIcons.ticket, AppColors.accent2_100, AppColors.accent2_700, 'AED 10 off voucher', 200, points, onTap: () {
                    if (points >= 200) ref.read(pawPointsProvider.notifier).state = points - 200;
                  }),
                  const SizedBox(height: 10),
                  _redeem(LucideIcons.bath, AppColors.accent100, AppColors.accent700, 'Free grooming kit', 500, points),
                  const SizedBox(height: 10),
                  _redeem(LucideIcons.gift, AppColors.neutral100, AppColors.neutral700, 'Surprise toy box', 800, points),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          Icon(icon, size: 17, color: AppColors.accent700),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.body(size: 13, weight: FontWeight.w600))),
        ]),
      );

  Widget _redeem(IconData icon, Color bg, Color fg, String title, int cost, int have, {VoidCallback? onTap}) {
    final canRedeem = have >= cost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: AppShadow.sm),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, size: 19, color: fg)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppText.body(size: 13.5, weight: FontWeight.w700)),
              Text('$cost points', style: AppText.body(size: 12, color: AppColors.neutral600)),
            ],
          ),
        ),
        PillButton(
          label: canRedeem ? 'Redeem' : '${cost - have} to go',
          height: 36,
          fontSize: 12.5,
          variant: canRedeem ? PillVariant.primary : PillVariant.secondary,
          enabled: canRedeem,
          onTap: onTap ?? () {},
        ),
      ]),
    );
  }
}
