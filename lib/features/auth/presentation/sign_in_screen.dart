import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  bool _sending = false;

  Future<void> _continue() async {
    final rawPhone = _phoneController.text.trim().replaceAll(' ', '');
    if (rawPhone.isEmpty) return;
    final fullPhone = '+971$rawPhone';

    setState(() => _sending = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: fullPhone);
      ref.read(phoneNumberProvider.notifier).state = fullPhone;
      if (mounted) context.go(R.otp);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _guest() async {
    try {
      await signInAsGuest();
      if (mounted) context.go(R.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 230,
                decoration: const BoxDecoration(
                  color: AppColors.accent2_200,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(60)),
                ),
                alignment: Alignment.center,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: AppShadow.md),
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.pets, size: 44, color: AppColors.bg),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 32, 26, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Welcome to PawMart',
                        style: AppText.heading(size: 28)),
                    const SizedBox(height: 6),
                    Text('Sign in to shop for your furry family.',
                        style: AppText.body(
                            size: 14, color: AppColors.neutral700)),
                    const SizedBox(height: 18),
                    Text('Phone number',
                        style: AppText.body(
                            size: 12, color: AppColors.neutral600)),
                    const SizedBox(height: 6),
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.phone,
                              size: 18, color: AppColors.neutral600),
                          const SizedBox(width: 10),
                          Text('+971',
                              style: AppText.body(
                                  size: 15, weight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: AppText.body(size: 15),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: '50 123 4567',
                                hintStyle: AppText.body(
                                    size: 15, color: AppColors.neutral500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PillButton(
                        label: _sending ? 'Sending...' : 'Continue',
                        height: 52,
                        onTap: _sending ? null : _continue),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with',
                              style: AppText.body(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: AppColors.neutral600)),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PillButton(
                        label: 'Continue with Google',
                        variant: PillVariant.secondary,
                        height: 50,
                        onTap: () => context.go(R.home)),
                    const SizedBox(height: 10),
                    PillButton(
                        label: 'Continue with Apple',
                        variant: PillVariant.secondary,
                        height: 50,
                        onTap: () => context.go(R.home)),
                    const SizedBox(height: 22),
                    Center(
                      child: TextButton(
                        onPressed: _guest,
                        child: Text('Browse as guest',
                            style: AppText.body(
                                size: 14,
                                weight: FontWeight.w700,
                                color: AppColors.accent)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
