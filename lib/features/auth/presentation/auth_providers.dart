import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/push/push_service.dart';
import '../../../core/config/env.dart';

final phoneNumberProvider = StateProvider<String>((ref) => '');

Future<void> signInAsGuest() async {
  await Supabase.instance.client.auth.signInAnonymously();
  await PushService.syncTokenIfAlreadyAuthorized();
}

/// Returns true on success, false if the user cancelled or it failed.
/// NOTE: unlike the phone-OTP path, this does not currently merge into an
/// existing guest (anonymous) session — signing in with Google starts a
/// session under the Google-linked account. Merging guest-cart history
/// into a Google sign-in would need Supabase's identity-linking flow,
/// which is a separate piece of work from just getting Google auth
/// working.
Future<bool> signInWithGoogle() async {
  try {
    final googleSignIn = GoogleSignIn(
      serverClientId: Env.googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false; // user cancelled the picker

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) return false;

    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );

    await PushService.syncTokenIfAlreadyAuthorized();
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> requestPhoneLink(String phone) async {
  await Supabase.instance.client.auth.updateUser(
    UserAttributes(phone: phone),
  );
}

Future<bool> verifyPhoneLink(String phone, String code) async {
  try {
    await Supabase.instance.client.auth.verifyOTP(
      type: OtpType.phoneChange,
      phone: phone,
      token: code,
    );
    await PushService.syncTokenIfAlreadyAuthorized();
    return true;
  } catch (e) {
    return false;
  }
}

class OtpState {
  const OtpState(
      {this.digits = const ['', '', '', '', '', ''],
      this.secondsLeft = 24,
      this.verifying = false});
  final List<String> digits;
  final int secondsLeft;
  final bool verifying;

  bool get isComplete => digits.every((d) => d.isNotEmpty);

  OtpState copyWith(
          {List<String>? digits, int? secondsLeft, bool? verifying}) =>
      OtpState(
        digits: digits ?? this.digits,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        verifying: verifying ?? this.verifying,
      );
}

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier(this.phone) : super(const OtpState()) {
    _startTimer();
  }

  final String phone;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(secondsLeft: 24);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsLeft <= 0) {
        t.cancel();
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  Future<void> resend() async {
    await Supabase.instance.client.auth.signInWithOtp(phone: phone);
    _startTimer();
  }

  void setDigit(int index, String value) {
    final next = [...state.digits];
    next[index] = value;
    state = state.copyWith(digits: next);
  }

  void setVerifying(bool v) => state = state.copyWith(verifying: v);

  Future<bool> verify() async {
    setVerifying(true);
    try {
      final code = state.digits.join();
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: code,
      );
      await PushService.syncTokenIfAlreadyAuthorized();
      return true;
    } catch (e) {
      setVerifying(false);
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpProvider = StateNotifierProvider.autoDispose<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(ref.read(phoneNumberProvider)),
);
