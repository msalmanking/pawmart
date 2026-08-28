# PawMart — Flutter app (Riverpod)

Full implementation of all 22 reference screens: animated splash, animated onboarding,
sign-in, OTP verify, home, categories, product listing + filters sheet, search, product
detail, reviews, cart, checkout, order-placed, orders, order tracking, profile, wishlist,
notifications, offers, Paw Points, live chat.

## Stack
- **State management:** `flutter_riverpod` (providers in `lib/core/providers/app_providers.dart`)
- **Navigation:** `go_router` (routes in `lib/core/router/app_router.dart`)
- **Fonts:** `google_fonts` — Caprasimo for headings, Figtree for body (matches the reference design tokens)
- **Icons:** `lucide_icons` (same icon set as the reference mocks)
- **Theme/tokens:** `lib/core/theme/app_colors.dart` + `app_theme.dart` — cream background,
  terracotta primary accent, sage secondary accent, pill-shaped controls, soft shadows —
  ported 1:1 from the reference CSS custom properties.

## Project structure
```
lib/
  core/
    theme/        — colors, typography, spacing, radius, shadow tokens
    providers/     — Riverpod state: cart, wishlist, pets, OTP timer, onboarding page, points
    router/        — go_router route table (R.xxx constants — one per screen)
    widgets/        — shared components: PillButton, AppTag, PhotoPlaceholder, PawBottomNav
  features/
    splash/         — 01 animated splash
    onboarding/     — 02 animated onboarding (PageView + dot indicator)
    auth/           — 03 sign-in, 04 OTP verify (with live countdown timer)
    home/           — 05 home
    categories/     — 06 categories
    product/        — 07 listing, 08 filters sheet, 09 (see search/), 10 detail, 11 reviews
    search/         — 09 search
    cart/           — 12 cart
    checkout/       — 13 checkout, 14 order placed
    orders/         — 15 orders, 16 order tracking
    profile/        — 17 profile, 18 wishlist, 19 notifications, 20 offers,
                      21 Paw Points, 22 live chat
```

## Why it won't overflow at the bottom
Every screen follows the same pattern that caused the bug in the original build:
- Scrollable content lives in `ListView` / `CustomScrollView` / `SingleChildScrollView`,
  **never** in a plain `Column` with a fixed-height screen.
- Sticky bottom bars (Add to cart, Checkout total, Place order, chat input) are placed in
  `Scaffold.bottomNavigationBar` or as a separate `Container` below the scroll view — not
  inside it — and pad for `MediaQuery.of(context).padding.bottom` so they clear the home
  indicator / gesture bar on notched devices.
- `PawBottomNav` has a fixed height + `SafeArea(top: false)`, so it never grows to fight
  the body for space.
- Text that can vary in length (product titles, review bodies) uses `maxLines` +
  `TextOverflow.ellipsis` or `Expanded`/`Flexible`, never a bare `Text` in a tight `Row`.

## Animations included
- **Splash:** logo scale-in (elastic) + fade, tagline slide-up, pulsing background circles,
  animated progress dots, auto-navigates after ~2.4s.
- **Onboarding:** `PageView` with eased page transitions, icon bounce-in per page,
  animated pill/dot page indicator, Skip button.
- **OTP:** per-digit auto-advance, animated focus border, live `Timer`-driven countdown
  via a Riverpod `StateNotifier`, button disables until 4 digits are filled.
- **Order placed:** elastic checkmark pop-in, staggered fade for the confirmation text.
- **Order tracking:** fade-in timeline steps, colored progress line.
- **Paw Points:** animated count-up and animated progress bar on load.
- **Live chat:** looping "typing…" dot animation.
- Buttons (`PillButton`) have a press-scale micro-interaction everywhere they're used.

## Run it
This is a plain Flutter package (no platform folders included, to keep the deliverable
lightweight). To run:

```bash
flutter create --project-name pawmart --org com.pawmart .   # generates android/ios/etc. in place
flutter pub get
flutter run
```

If `flutter create .` complains about existing files, just create a fresh
`flutter create pawmart_shell`, then copy this `lib/` and `pubspec.yaml` into it.

## Extending
- Replace `PhotoPlaceholder` usages with real `Image.network`/`Image.asset` once you have
  product photography — the striped block is a deliberate stand-in, matching the reference.
- Cart/points state lives in Riverpod providers — swap the in-memory `StateNotifier`s for
  ones backed by your API/DB without touching any screen widget.
