import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/notifications/data/device_token_repository.dart';

/// Background message handler. Must be a top-level (or static) function —
/// Firebase spins this up in its own isolate when a data message arrives
/// while the app is backgrounded or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally minimal: when a push has a `notification` payload (the
  // recommended shape per the runbook), Android shows the tray
  // notification itself with no code needed here. This handler just
  // satisfies firebase_messaging's requirement that one be registered,
  // and is the place to add data-only handling later if ever needed.
}

class PushService {
  PushService._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Set whenever the user taps a push (from background or terminated).
  /// A widget higher up (see `DeepLinkListener`) turns this into
  /// navigation once the router and providers are ready.
  static final ValueNotifier<Map<String, dynamic>?> pendingDeepLink =
      ValueNotifier(null);

  /// Call once, early in `main()`, after `Firebase.initializeApp()`.
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
    );

    // Foreground: the OS does NOT show a tray notification by itself while
    // the app is open, so show one manually via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pawmart_default',
            'PawMart notifications',
            channelDescription: 'Order updates, offers, and account alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    // User tapped a push while the app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      pendingDeepLink.value = message.data;
    });

    // App was fully terminated and got launched by tapping a push.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      pendingDeepLink.value = initialMessage.data;
    }

    // Keep Supabase in sync if the token rotates while the app is running.
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  }

  /// Local key for the most recent token *this device* successfully
  /// registered. Used to clean up the old row in Supabase whenever the
  /// token changes (fresh install, app data cleared, token rotation) so
  /// one physical device doesn't accumulate dead rows in `device_tokens`
  /// over time — important for a production app, not just dev testing.
  static const _lastTokenKey = 'push_last_registered_token';

  static Future<void> _registerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final previous = prefs.getString(_lastTokenKey);
    final repo = DeviceTokenRepository(Supabase.instance.client);

    if (previous != null && previous != token) {
      await repo.deleteToken(previous);
    }

    await repo.saveToken(token);
    await prefs.setString(_lastTokenKey, token);
  }

  /// Whether we should show our own "Get delivery updates?" prompt.
  ///
  /// NOTE: this deliberately does NOT rely on
  /// `FirebaseMessaging.getNotificationSettings().authorizationStatus`.
  /// On Android that call collapses "never asked" and "user said no"
  /// into the same `denied` value (there's no Android equivalent of
  /// iOS's `notDetermined`), so checking for `notDetermined` there would
  /// never be true and our sheet would never show. Instead we track
  /// "have we asked on this device" ourselves.
  static const _askedKey = 'push_permission_asked';

  static Future<bool> shouldShowPermissionPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return false;

    // If the user already enabled notifications some other way (e.g. from
    // phone Settings) there's nothing to ask — just remember that and
    // move on.
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await prefs.setBool(_askedKey, true);
      return false;
    }

    return true;
  }

  /// Marks the prompt as shown so we never ask again on this device,
  /// regardless of what the user chose.
  static Future<void> markPermissionPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
  }

  /// Requests notification permission and, if granted, stores this
  /// device's FCM token against the signed-in user.
  ///
  /// Per the runbook, call this after a meaningful moment — e.g. right
  /// after the user's first order is placed — NOT on app launch. Asking
  /// on first launch tends to get an automatic "Deny" with no way to
  /// re-prompt on iOS, so save the ask for when the value is obvious.
  /// Callers should gate this behind [shouldShowPermissionPrompt] so it
  /// only ever runs once per device.
  static Future<void> requestPermissionAndRegister() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await markPermissionPromptShown();

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(token);
    }
  }

  /// If the user already granted permission in a previous session, quietly
  /// (re-)registers this device's token. Call after login so a returning
  /// user keeps receiving pushes without being re-prompted.
  static Future<void> syncTokenIfAlreadyAuthorized() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(token);
    }
  }

  /// Call on logout so this device stops being associated with the
  /// account that just signed out.
  static Future<void> unregisterToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await DeviceTokenRepository(Supabase.instance.client).deleteToken(token);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastTokenKey);
  }
}
