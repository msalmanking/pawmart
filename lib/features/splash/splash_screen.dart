import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();

  late final Animation<double> _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut));
  late final Animation<double> _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut));
  late final Animation<double> _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut));
  late final Animation<Offset> _textSlide =
      Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.35, 0.7, curve: Curves.easeOut)));
  late final Animation<double> _dotsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

  int _activeDot = 0;
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();
    _decideNextRoute();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _dotsTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
        if (!mounted) return;
        setState(() => _activeDot = (_activeDot + 1) % 3);
      });
    });
  }

  /// Checks session + onboarding-seen flag. Has a hard 3s timeout so a slow
  /// or unreachable Supabase never leaves the splash screen stuck.
  Future<void> _decideNextRoute() async {
    String nextRoute = R.onboarding;

    try {
      await Future.any([
        _resolveRoute().then((route) => nextRoute = route),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (_) {
      // Fall back to onboarding on any error.
    }

    // Keep the splash visible for at least ~1.6s so the entry animation
    // doesn't feel jarring on fast/cached sessions.
    await Future.delayed(const Duration(milliseconds: 1600));

    if (mounted) context.go(nextRoute);
  }

  Future<String> _resolveRoute() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return R.home;
    }

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    return seenOnboarding ? R.signIn : R.onboarding;
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            right: -70,
            child: _pulsingCircle(200, AppColors.accent400.withOpacity(0.5)),
          ),
          Positioned(
            bottom: -90,
            left: -60,
            child: _pulsingCircle(240, AppColors.accent700.withOpacity(0.45)),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          shape: BoxShape.circle,
                          boxShadow: AppShadow.md,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pets,
                            size: 54, color: AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text('PawMart',
                              style: AppText.heading(
                                  size: 44, color: AppColors.bg)),
                          const SizedBox(height: 6),
                          Text('Everything your pet loves',
                              style: AppText.body(
                                  size: 16,
                                  weight: FontWeight.w600,
                                  color: AppColors.accent200)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _dotsFade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final isActive = i == _activeDot;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 26 : 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color:
                                isActive ? AppColors.bg : AppColors.accent300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulsingCircle(double size, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeInOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}
