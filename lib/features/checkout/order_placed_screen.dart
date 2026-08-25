import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class OrderPlacedScreen extends ConsumerStatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  ConsumerState<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends ConsumerState<OrderPlacedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();
  late final Animation<double> _checkScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut));
  late final Animation<double> _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut));

  // Note: the cart is cleared from CheckoutScreen's "Place order" button
  // (a user event) right before navigating here — NOT in this screen's
  // initState/build. Mutating a provider during another widget's build
  // phase is what caused the earlier crash ("Tried to modify a provider
  // while the widget tree was building").

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
              top: -60, left: -60, child: _circle(190, AppColors.accent2_200)),
          Positioned(
              bottom: -70,
              right: -50,
              child: _circle(210, AppColors.accent200)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _checkScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            color: AppColors.accent2,
                            shape: BoxShape.circle,
                            boxShadow: AppShadow.md),
                        child: const Icon(LucideIcons.check,
                            size: 54, color: AppColors.bg),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text('Treats are on the way!',
                              textAlign: TextAlign.center,
                              style: AppText.heading(size: 30)),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                                style: AppText.body(
                                    size: 14.5,
                                    color: AppColors.neutral700,
                                    height: 1.6),
                                children: const [
                                  TextSpan(text: 'Order '),
                                  TextSpan(
                                      text: '#PM-84291',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text)),
                                  TextSpan(
                                      text:
                                          ' is confirmed.\nArriving tomorrow, 9 am – 1 pm.'),
                                ]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeTransition(
                      opacity: _textFade,
                      child: const AppTag(
                          label: '+23 Paw Points earned',
                          icon: LucideIcons.medal,
                          variant: TagVariant.accent2Soft),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                          label: 'Track my order',
                          height: 52,
                          onTap: () => context.pushReplacement(R.tracking)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: 'Continue shopping',
                        variant: PillVariant.ghost,
                        height: 44,
                        onTap: () => context.go(R.home),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
