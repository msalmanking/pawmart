import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../presentation/offers_providers.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Offers & deals'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        children: [
          bannersAsync.when(
            loading: () => const SizedBox(
              height: 140,
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (err, _) => Text('Error: $err',
                style: AppText.body(size: 12, color: AppColors.neutral600)),
            data: (banners) {
              if (banners.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 150,
                child: PageView.builder(
                  itemCount: banners.length,
                  itemBuilder: (context, i) {
                    final b = banners[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        color: AppColors.accent,
                        child: Row(children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 22, top: 22, right: 8, bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(b.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.heading(
                                          size: 20, color: AppColors.bg)),
                                  const SizedBox(height: 4),
                                  if (b.subtitle != null)
                                    Text(b.subtitle!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.body(
                                            size: 12.5,
                                            weight: FontWeight.w600,
                                            color: AppColors.accent200)),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: 104,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: AppColors.bg,
                                        borderRadius:
                                            BorderRadius.circular(999)),
                                    alignment: Alignment.center,
                                    child: Text('Shop sale',
                                        style: AppText.body(
                                            size: 12,
                                            weight: FontWeight.w700,
                                            color: AppColors.accent800)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: b.imageUrl != null
                                ? Image.network(
                                    b.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => PhotoPlaceholder(
                                        label: b.title, radius: 0),
                                  )
                                : PhotoPlaceholder(label: b.title, radius: 0),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Your coupons',
              style: AppText.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.neutral700)),
          const SizedBox(height: 10),
          couponsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
            ),
            error: (err, _) => Text('Error: $err',
                style: AppText.body(size: 12, color: AppColors.neutral600)),
            data: (coupons) {
              if (coupons.isEmpty) {
                return Text('No active coupons right now',
                    style: AppText.body(size: 13, color: AppColors.neutral600));
              }
              return Column(
                children: [
                  for (final c in coupons) ...[
                    _coupon(
                      LucideIcons.percent,
                      AppColors.accent,
                      AppColors.accent100,
                      AppColors.accent400,
                      c.displayValue,
                      c.minSpend > 0
                          ? 'Min. spend AED ${c.minSpend.toStringAsFixed(0)}'
                          : 'No minimum spend',
                      c.code,
                      AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Text('Deals of the day',
              style: AppText.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.neutral700)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _dealCard('litter box', 'PurePaws Litter Box + Scoop',
                    'AED 55', 'AED 79', '-30%')),
            const SizedBox(width: 14),
            Expanded(
                child: _dealCard('heat lamp', 'SunBask Reptile Heat Lamp',
                    'AED 89', 'AED 119', '-25%')),
          ]),
        ],
      ),
    );
  }

  Widget _coupon(IconData icon, Color iconBg, Color cardBg, Color borderColor,
      String title, String subtitle, String code, Color codeColor) {
    return DottedBorderContainer(
      color: borderColor,
      bg: cardBg,
      child: Row(children: [
        Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.white)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: AppText.body(size: 14, weight: FontWeight.w700)),
              Text(subtitle,
                  style: AppText.body(size: 12, color: AppColors.neutral700)),
            ],
          ),
        ),
        AppTag(label: code, variant: TagVariant.outline, dense: true),
      ]),
    );
  }

  Widget _dealCard(
      String photo, String title, String price, String oldPrice, String badge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.35,
          child: Stack(children: [
            Positioned.fill(child: PhotoPlaceholder(label: photo, radius: 22)),
            Positioned(
                top: 8,
                left: 8,
                child: AppTag(
                    label: badge, variant: TagVariant.accentSoft, dense: true)),
          ]),
        ),
        const SizedBox(height: 6),
        Text(title,
            style:
                AppText.body(size: 12.5, weight: FontWeight.w600, height: 1.3)),
        Row(children: [
          Text(price, style: AppText.body(size: 13.5, weight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text(oldPrice,
              style: AppText.body(size: 11, color: AppColors.neutral500)
                  .copyWith(decoration: TextDecoration.lineThrough)),
        ]),
      ],
    );
  }
}

class DottedBorderContainer extends StatelessWidget {
  const DottedBorderContainer(
      {super.key, required this.child, required this.color, required this.bg});
  final Widget child;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 2, style: BorderStyle.solid)),
      child: child,
    );
  }
}
