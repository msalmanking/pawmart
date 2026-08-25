import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---- Simple app-wide state -------------------------------------------

final wishlistCountProvider = StateProvider<int>((ref) => 4);
final selectedPetIndexProvider = StateProvider<int>((ref) => 0);
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final pawPointsProvider = StateProvider<int>((ref) => 340);

/// ---- Onboarding page index ---------------------------------------------

final onboardingPageProvider = StateProvider<int>((ref) => 0);

/// ---- Cart line items (legacy local demo data — no longer used by CartScreen,
/// kept only so old references don't break; safe to delete once confirmed unused) --

class CartItem {
  CartItem(
      {required this.name,
      required this.variant,
      required this.price,
      required this.qty});
  final String name;
  final String variant;
  final double price;
  int qty;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void inc(int i) {
    state[i].qty++;
    state = [...state];
  }

  void dec(int i) {
    if (state[i].qty > 1) state[i].qty--;
    state = [...state];
  }

  void remove(int i) {
    final next = [...state]..removeAt(i);
    state = next;
  }

  double get subtotal =>
      state.fold(0, (sum, item) => sum + item.price * item.qty);
}

final cartItemsProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
    (ref) => CartNotifier());
