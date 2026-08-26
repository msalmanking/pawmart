import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../presentation/points_providers.dart';

class PawPointsScreen extends ConsumerWidget {
  const PawPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(pointsHistoryProvider);
    final points = ref.watch(pointsBalanceProvider);
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
              decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(48))),
              child: Column(
                children: [
                  Row(children: [
                    IconButton(
                        icon: const Icon(LucideIcons.arrowLeft,
                            color: AppColors.bg),
                        onPressed: () => Navigator.of(context).maybePop()),
                    Text('Paw Points',
                        style: AppText.heading(size: 21, color: AppColors.bg)),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                        color: AppColors.accent400, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.medal,
                        size: 36, color: AppColors.bg),
                  ),
                  const SizedBox(height: 8),
                  historyAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CircularProgressIndicator(color: AppColors.bg),
                    ),
                    error: (err, _) => Text('Error: $err',
                        style: AppText.body(size: 12, color: AppColors.bg)),
                    data: (_) => TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: points),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text('$value',
                          style:
                              AppText.heading(size: 42, color: AppColors.bg)),
                    ),
                  ),
                  Text('points · worth AED ${(points / 20).toStringAsFixed(0)}',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.accent200)),
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
                  Text(
                      points >= target
                          ? 'You have enough points for your next reward!'
                          : '${target - points} points to your next reward — free grooming kit',
                      textAlign: TextAlign.center,
                      style: AppText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: AppColors.accent200)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to earn',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.neutral700)),
                  const SizedBox(height: 10),
                  _pill(LucideIcons.shoppingBag, '1 point per AED 10 spent'),
                  const SizedBox(height: 8),
                  _pill(LucideIcons.star, '5 points per product review'),
                  const SizedBox(height: 8),
                  _pill(LucideIcons.users, '50 points per friend referred'),
                  const SizedBox(height: 22),
                  Text('Redeem',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.neutral700)),
                  const SizedBox(height: 10),
                  _redeem(
                      context,
                      ref,
                      LucideIcons.ticket,
                      AppColors.accent2_100,
                      AppColors.accent2_700,
                      'AED 10 off voucher',
                      200,
                      points),
                  const SizedBox(height: 10),
                  _redeem(context, ref, LucideIcons.bath, AppColors.accent100,
                      AppColors.accent700, 'Free grooming kit', 500, points),
                  const SizedBox(height: 10),
                  _redeem(context, ref, LucideIcons.gift, AppColors.neutral100,
                      AppColors.neutral700, 'Surprise toy box', 800, points),
                  const SizedBox(height: 22),
                  Text('History',
                      style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.neutral700)),
                  const SizedBox(height: 10),
                  historyAsync.when(
                    loading: () => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent)),
                    error: (err, _) => Text('Error: $err',
                        style: AppText.body(
                            size: 12, color: AppColors.neutral600)),
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Text('No points activity yet',
                            style: AppText.body(
                                size: 13, color: AppColors.neutral600));
                      }
                      return Column(
                        children: [
                          for (final e in entries) ...[
                            _historyRow(e.reason, e.delta),
                            const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                  ),
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
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          Icon(icon, size: 17, color: AppColors.accent700),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: AppText.body(size: 13, weight: FontWeight.w600))),
        ]),
      );
  Widget _redeem(BuildContext context, WidgetRef ref, IconData icon, Color bg,
      Color fg, String title, int cost, int have) {
    final canRedeem = have >= cost;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool processing = false;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadow.sm),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: fg)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppText.body(size: 13.5, weight: FontWeight.w700)),
                  Text('$cost points',
                      style:
                          AppText.body(size: 12, color: AppColors.neutral600)),
                ],
              ),
            ),
            PillButton(
              label: processing
                  ? '...'
                  : (canRedeem ? 'Redeem' : '${cost - have} to go'),
              height: 36,
              fontSize: 12.5,
              variant: canRedeem ? PillVariant.primary : PillVariant.secondary,
              enabled: canRedeem && !processing,
              onTap: (canRedeem && !processing)
                  ? () async {
                      final currentBalance = ref.read(pointsBalanceProvider);
                      if (currentBalance < cost) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Not enough points')));
                        return;
                      }
                      setLocalState(() => processing = true);
                      try {
                        await redeemPoints(ref,
                            cost: cost, reason: 'Redeemed for $title');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Redeemed: $title')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red));
                        }
                      } finally {
                        setLocalState(() => processing = false);
                      }
                    }
                  : () {},
            ),
          ]),
        );
      },
    );
  }

  Widget _historyRow(String reason, int delta) {
    final positive = delta >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(positive ? LucideIcons.plus : LucideIcons.minus,
            size: 14,
            color: positive ? AppColors.accent2_700 : AppColors.neutral600),
        const SizedBox(width: 10),
        Expanded(
            child: Text(reason,
                style: AppText.body(size: 13, weight: FontWeight.w600))),
        Text('${positive ? '+' : ''}$delta',
            style: AppText.body(
                size: 13,
                weight: FontWeight.w700,
                color:
                    positive ? AppColors.accent2_700 : AppColors.neutral700)),
      ]),
    );
  }
}
