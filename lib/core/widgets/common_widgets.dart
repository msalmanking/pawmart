import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Pill-shaped primary/secondary/ghost button with a press-scale animation.
/// Buttons never force a fixed width themselves — callers decide (SizedBox /
/// Expanded), which is what keeps rows from overflowing.
class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.variant = PillVariant.primary,
    this.height = 52,
    this.fontSize = 15,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final PillVariant variant;
  final double height;
  final double fontSize;
  final bool enabled;

  @override
  State<PillButton> createState() => _PillButtonState();
}

enum PillVariant { primary, secondary, ghost, dark }

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || widget.onTap == null;

    Color bg;
    Color fg;
    Border? border;
    switch (widget.variant) {
      case PillVariant.primary:
        bg = AppColors.accent;
        fg = AppColors.bg;
        border = null;
        break;
      case PillVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.text;
        border = Border.all(color: AppColors.divider);
        break;
      case PillVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.accent;
        border = null;
        break;
      case PillVariant.dark:
        bg = AppColors.neutral900;
        fg = AppColors.bg;
        border = null;
        break;
    }

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _scale = 0.96),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: disabled ? null : widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: border),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading(size: widget.fontSize, color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag(
      {super.key,
      required this.label,
      this.variant = TagVariant.neutral,
      this.icon,
      this.dense = false});
  final String label;
  final TagVariant variant;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    Border? border;
    switch (variant) {
      case TagVariant.accent:
        bg = AppColors.accent;
        fg = AppColors.bg;
        break;
      case TagVariant.accentSoft:
        bg = AppColors.accent100;
        fg = AppColors.accent800;
        break;
      case TagVariant.accent2Soft:
        bg = AppColors.accent2_100;
        fg = AppColors.accent2_800;
        break;
      case TagVariant.neutral:
        bg = AppColors.neutral100;
        fg = AppColors.neutral800;
        break;
      case TagVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.accent;
        border = Border.all(color: AppColors.accent);
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 14, vertical: dense ? 5 : 8),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: border),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 5)
          ],
          Text(label,
              style: AppText.body(
                  size: dense ? 11 : 12.5, weight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

enum TagVariant { accent, accentSoft, accent2Soft, neutral, outline }

/// Photo drop-zone placeholder — striped block, exactly like the reference
/// mock, so real product photography can be swapped in later.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder(
      {super.key, this.label = 'photo', this.radius = 20, this.icon});
  final String label;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(painter: _StripePainter(), size: Size.infinite),
          if (icon != null)
            Icon(icon, size: 28, color: AppColors.neutral500)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(999)),
              child: Text('[$label]',
                  style: AppText.body(size: 9, color: AppColors.neutral700)),
            ),
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = AppColors.neutral200);
    final paint = Paint()
      ..color = AppColors.neutral300
      ..strokeWidth = 10;
    const gap = 16.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom tab bar used by Home / Categories / Cart / Wishlist / Profile.
/// Fixed height + SafeArea so it never fights the body for space.
class PawBottomNav extends StatelessWidget {
  const PawBottomNav(
      {super.key,
      required this.currentIndex,
      required this.onTap,
      this.cartCount = 0});
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  static const _items = [
    (Icons.pets, 'Home'),
    (LucideIcons.layoutGrid, 'Shop'),
    (LucideIcons.shoppingCart, 'Cart'),
    (LucideIcons.heart, 'Wishlist'),
    (LucideIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.neutral100,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final color = selected ? AppColors.accent : AppColors.neutral600;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_items[i].$1, size: 22, color: color),
                          const SizedBox(height: 3),
                          Text(_items[i].$2,
                              style: AppText.body(
                                  size: 10.5,
                                  weight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: color)),
                        ],
                      ),
                      if (i == 2 && cartCount > 0)
                        Positioned(
                          top: 2,
                          right: MediaQuery.of(context).size.width *
                                  0.5 /
                                  _items.length -
                              14,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              key: ValueKey(cartCount),
                              constraints: const BoxConstraints(minWidth: 16),
                              height: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text('$cartCount',
                                  style: AppText.body(
                                      size: 9.5,
                                      weight: FontWeight.w700,
                                      color: AppColors.bg)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Simple app-bar with back button, used across detail/sub screens.
PreferredSizeWidget simpleAppBar(BuildContext context, String title,
    {List<Widget>? actions}) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(LucideIcons.arrowLeft),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    title: Text(title, style: AppText.heading(size: 20)),
    actions: actions,
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
      {super.key, required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                style: AppText.heading(size: 19),
                overflow: TextOverflow.ellipsis)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: AppText.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
      ],
    );
  }
}
