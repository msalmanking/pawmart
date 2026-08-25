import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class _Page {
  const _Page(this.title, this.body, this.icon, this.bg);
  final String title;
  final String body;
  final IconData icon;
  final Color bg;
}

const _pages = [
  _Page(
      'One store for every pet',
      'Food, toys, grooming, health and training gear — for dogs, cats, birds, fish and more. Delivered to your door.',
      LucideIcons.dog,
      AppColors.accent2_200),
  _Page(
      'Same-day delivery, always fresh',
      'Order before 2pm and get it today. Every item is checked for freshness before it leaves the warehouse.',
      LucideIcons.truck,
      AppColors.accent200),
  _Page(
      'Earn Paw Points on everything',
      'Collect points on every order and redeem them for grooming kits, toys and vouchers.',
      LucideIcons.medal,
      AppColors.accent2_200),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
  }

  void _next() async {
    final page = ref.read(onboardingPageProvider);
    if (page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic);
    } else {
      await _markOnboardingSeen();
      if (mounted) context.go(R.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(onboardingPageProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextButton(
                  onPressed: () async {
                    await _markOnboardingSeen();
                    if (context.mounted) context.go(R.signIn);
                  },
                  child: Text('Skip',
                      style: AppText.body(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) =>
                    ref.read(onboardingPageProvider.notifier).state = i,
                itemBuilder: (context, i) => _OnboardPage(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 44),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 26 : 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.accent : AppColors.neutral300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: page == _pages.length - 1 ? 'Get started' : 'Next',
                      height: 54,
                      fontSize: 16,
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Scrollable so small phones never overflow, even with big type.
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(page.title),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                builder: (context, v, child) => Transform.scale(
                    scale: 0.85 + 0.15 * v,
                    child: Opacity(opacity: v.clamp(0, 1), child: child)),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration:
                      BoxDecoration(color: page.bg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(page.icon,
                      size: 96, color: AppColors.text.withOpacity(0.75)),
                ),
              ),
              const SizedBox(height: 30),
              Text(page.title,
                  textAlign: TextAlign.center,
                  style: AppText.heading(size: 28)),
              const SizedBox(height: 12),
              Text(page.body,
                  textAlign: TextAlign.center,
                  style: AppText.body(
                      size: 15, color: AppColors.neutral700, height: 1.6)),
            ],
          ),
        ),
      );
    });
  }
}
