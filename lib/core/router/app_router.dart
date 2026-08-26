import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/catalog/presentation/categories_screen.dart';
import '../../features/product/product_listing_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/product/reviews_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_placed_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/orders/presentation/order_tracking_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/offers/presentation/offers_screen.dart';
import '../../features/paw_points/presentation/paw_points_screen.dart';
import '../../features/profile/live_chat_screen.dart';
import '../../features/addresses/presentation/addresses_screen.dart';

/// Route names — one per screen in the reference set (01–22).
class R {
  R._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const otp = '/otp';
  static const home = '/home';
  static const categories = '/categories';
  static const listing = '/listing';
  static const search = '/search';
  static const productDetail = '/product';
  static const reviews = '/reviews';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderPlaced = '/order-placed';
  static const orders = '/orders';
  static const tracking = '/tracking';
  static const profile = '/profile';
  static const wishlist = '/wishlist';
  static const notifications = '/notifications';
  static const offers = '/offers';
  static const pawPoints = '/paw-points';
  static const liveChat = '/live-chat';
  static const addresses = '/addresses';
}

final appRouter = GoRouter(
  initialLocation: R.splash,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggedIn = session != null;

    const authRoutes = [R.splash, R.onboarding, R.signIn, R.otp];
    const protectedRoutes = [
      R.cart,
      R.checkout,
      R.orderPlaced,
      R.orders,
      R.tracking,
      R.profile,
      R.wishlist,
      R.addresses,
      R.pawPoints,
      R.notifications,
    ];

    final goingToAuthRoute = authRoutes.contains(state.matchedLocation);
    final goingToProtectedRoute =
        protectedRoutes.contains(state.matchedLocation);

    if (!loggedIn && goingToProtectedRoute) {
      return R.signIn;
    }

    if (loggedIn &&
        (state.matchedLocation == R.signIn || state.matchedLocation == R.otp)) {
      return R.home;
    }

    return null;
  },
  routes: [
    GoRoute(path: R.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: R.onboarding, builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: R.signIn, builder: (_, __) => const SignInScreen()),
    GoRoute(path: R.otp, builder: (_, __) => const OtpScreen()),
    GoRoute(path: R.home, builder: (_, __) => const HomeScreen()),
    GoRoute(path: R.categories, builder: (_, __) => const CategoriesScreen()),
    GoRoute(path: R.listing, builder: (_, __) => const ProductListingScreen()),
    GoRoute(path: R.search, builder: (_, __) => const SearchScreen()),
    GoRoute(
        path: R.productDetail, builder: (_, __) => const ProductDetailScreen()),
    GoRoute(path: R.reviews, builder: (_, __) => const ReviewsScreen()),
    GoRoute(path: R.cart, builder: (_, __) => const CartScreen()),
    GoRoute(path: R.checkout, builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: R.orderPlaced, builder: (_, __) => const OrderPlacedScreen()),
    GoRoute(path: R.orders, builder: (_, __) => const OrdersScreen()),
    GoRoute(path: R.tracking, builder: (_, __) => const OrderTrackingScreen()),
    GoRoute(path: R.profile, builder: (_, __) => const ProfileScreen()),
    GoRoute(path: R.wishlist, builder: (_, __) => const WishlistScreen()),
    GoRoute(
        path: R.notifications, builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: R.offers, builder: (_, __) => const OffersScreen()),
    GoRoute(path: R.pawPoints, builder: (_, __) => const PawPointsScreen()),
    GoRoute(path: R.liveChat, builder: (_, __) => const LiveChatScreen()),
    GoRoute(path: R.addresses, builder: (_, __) => const AddressesScreen()),
  ],
);
