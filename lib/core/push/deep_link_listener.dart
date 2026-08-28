import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import 'push_service.dart';
import '../../features/orders/presentation/orders_providers.dart';
import '../../features/catalog/presentation/catalog_providers.dart';

/// Wraps the app and converts a tapped push notification's `data` payload
/// into in-app navigation, once the router and providers are ready.
///
/// Expected `data` shapes (set server-side when a push is sent), matching
/// the deep links called out in the runbook:
///   {"type": "order",   "id": "<order_id>"}   -> order tracking screen
///   {"type": "product", "id": "<product_id>"} -> product detail screen
///   {"type": "offers"}                         -> offers screen
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  @override
  void initState() {
    super.initState();
    PushService.pendingDeepLink.addListener(_handle);
    // Handles a deep link that was already pending before this widget
    // existed — e.g. the app was launched from terminated by a push tap.
    WidgetsBinding.instance.addPostFrameCallback((_) => _handle());
  }

  @override
  void dispose() {
    PushService.pendingDeepLink.removeListener(_handle);
    super.dispose();
  }

  void _handle() {
    final data = PushService.pendingDeepLink.value;
    if (data == null || data.isEmpty) return;
    PushService.pendingDeepLink.value = null; // consume once

    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'order':
        if (id is String) {
          ref.read(selectedOrderIdProvider.notifier).state = id;
          appRouter.push(R.tracking);
        }
        break;
      case 'product':
        if (id is String) {
          ref.read(selectedProductIdProvider.notifier).state = id;
          appRouter.push(R.productDetail);
        }
        break;
      case 'offers':
        appRouter.push(R.offers);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
