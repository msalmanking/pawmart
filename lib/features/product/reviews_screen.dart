import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int filter = 0;
  static const _bars = [0.82, 0.12, 0.04, 0.01, 0.01];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: simpleAppBar(context, 'Reviews'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('4.8', style: AppText.heading(size: 44)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) => Icon(LucideIcons.star, size: 14, color: i < 4 ? AppColors.accent : AppColors.accent200)),
                  ),
                  const SizedBox(height: 2),
                  Text('1,204 reviews', style: AppText.body(size: 12, color: AppColors.neutral600)),
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
                        SizedBox(width: 10, child: Text('$star', style: AppText.body(size: 11, weight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _bars[i],
                              minHeight: 8,
                              backgroundColor: AppColors.neutral200,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (int i = 0; i < 4; i++) ...[
                  GestureDetector(
                    onTap: () => setState(() => filter = i),
                    child: AppTag(
                      label: ['All', 'With photos', '5 ★', 'Critical'][i],
                      dense: true,
                      variant: i == filter ? TagVariant.accent : TagVariant.neutral,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _review('SR', AppColors.accent2_200, AppColors.accent2_800, 'Sara R.', 'Golden retriever parent · 2 days ago', 5,
              'Max is the pickiest eater I know and he cleans the bowl every time. Coat looks noticeably shinier after a month.',
              hasPhotos: true, helpful: 48),
          const SizedBox(height: 14),
          _review('OK', AppColors.accent200, AppColors.accent800, 'Omar K.', 'Verified purchase · 1 week ago', 4,
              'Good kibble size for medium dogs. Wish the 10 kg bag had a resealable zip — otherwise excellent value.',
              helpful: 19),
          const SizedBox(height: 20),
          PillButton(label: 'Write a review', icon: LucideIcons.pencil, variant: PillVariant.secondary, height: 50, onTap: () {}),
        ],
      ),
    );
  }

  Widget _review(String initials, Color avatarBg, Color avatarFg, String name, String meta, int stars, String body,
      {bool hasPhotos = false, required int helpful}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: AppShadow.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 19, backgroundColor: avatarBg, child: Text(initials, style: AppText.body(size: 13, weight: FontWeight.w700, color: avatarFg))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.body(size: 13, weight: FontWeight.w700)),
                    Text(meta, style: AppText.body(size: 11, color: AppColors.neutral600)),
                  ],
                ),
              ),
              Row(children: List.generate(5, (i) => Icon(LucideIcons.star, size: 12, color: i < stars ? AppColors.accent : AppColors.accent200))),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: AppText.body(size: 13, color: AppColors.neutral800, height: 1.55)),
          if (hasPhotos) ...[
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(width: 64, height: 64, child: PhotoPlaceholder(radius: 16)),
              const SizedBox(width: 8),
              SizedBox(width: 64, height: 64, child: PhotoPlaceholder(radius: 16)),
            ]),
          ],
          const SizedBox(height: 8),
          Row(children: [
            const Icon(LucideIcons.thumbsUp, size: 14, color: AppColors.neutral600),
            const SizedBox(width: 6),
            Text('Helpful ($helpful)', style: AppText.body(size: 12, color: AppColors.neutral600)),
          ]),
        ],
      ),
    );
  }
}
