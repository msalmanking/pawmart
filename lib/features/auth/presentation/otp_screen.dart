import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _nodes = List.generate(4, (_) => FocusNode());
  final _controllers = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String v) {
    ref.read(otpProvider.notifier).setDigit(i, v);
    if (v.isNotEmpty && i < 3) {
      _nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    if (ref.read(otpProvider).isComplete) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _verify() async {
    ref.read(otpProvider.notifier).setVerifying(true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) context.go(R.home);
  }

  @override
  Widget build(BuildContext context) {
    final otp = ref.watch(otpProvider);
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.bg,
      // Column with an Expanded scroll area on top and a fixed footer at the
      // bottom — this is what pins "Your number is only used…" near the very
      // bottom of the screen (like the reference), instead of it just
      // trailing right under the button with a big empty gap underneath.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 12, 26, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Check your phone', style: AppText.heading(size: 28)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: AppText.body(
                            size: 14, color: AppColors.neutral700, height: 1.6),
                        children: const [
                          TextSpan(text: 'We sent a 4-digit code to '),
                          TextSpan(
                              text: '+971 50 123 4567',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    // Each box lives in an Expanded slot capped at 64px, so
                    // the row always fits the available width — on a narrow
                    // window it shrinks instead of overflowing (this is what
                    // was causing the yellow/black overflow stripes).
                    Row(
                      children: List.generate(4, (i) {
                        final filled = otp.digits[i].isNotEmpty;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: 64, maxHeight: 64),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: filled
                                            ? AppColors.accent
                                            : AppColors.divider,
                                        width: filled ? 2 : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: TextField(
                                      controller: _controllers[i],
                                      focusNode: _nodes[i],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: AppText.heading(size: 26),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (v) => _onChanged(i, v),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: otp.secondsLeft > 0
                          ? RichText(
                              text: TextSpan(
                                style: AppText.body(
                                    size: 13, color: AppColors.neutral600),
                                children: [
                                  const TextSpan(text: 'Resend code in '),
                                  TextSpan(
                                    text:
                                        '00:${otp.secondsLeft.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent700),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () =>
                                  ref.read(otpProvider.notifier).resend(),
                              child: Text('Resend code',
                                  style: AppText.body(
                                      size: 13,
                                      weight: FontWeight.w700,
                                      color: AppColors.accent)),
                            ),
                    ),
                    const SizedBox(height: 28),
                    PillButton(
                      label: otp.verifying ? 'Verifying…' : 'Verify',
                      height: 52,
                      enabled: otp.isComplete && !otp.verifying,
                      onTap: _verify,
                    ),
                  ],
                ),
              ),
            ),
            // Fixed footer — always sits at the bottom of the screen.
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 28),
              child: Center(
                child: AppTag(
                  label: 'Your number is only used for orders & delivery',
                  variant: TagVariant.accent2Soft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
