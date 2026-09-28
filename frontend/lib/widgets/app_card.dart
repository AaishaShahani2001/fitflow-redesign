import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Rounded white surface used by every dashboard card.
///
/// Passing [onTap] makes the whole card tappable with a ripple.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.onTap,
    this.semanticLabel,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Defaults to the white card surface; tint it for highlighted cards.
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Semantics(
            label: semanticLabel,
            button: onTap != null,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Small tinted square holding a leading card icon.
class CardIconBadge extends StatelessWidget {
  const CardIconBadge({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.background,
    this.foreground,
    this.shape = BoxShape.rectangle,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.accent.withValues(alpha: 0.35),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(AppRadius.badge)
            : null,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foreground ?? AppColors.primary,
      ),
    );
  }
}

/// Icon + title row shared by the statistic cards.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconBackground,
    this.iconForeground,
  });

  final IconData icon;
  final String title;
  final Color? iconBackground;
  final Color? iconForeground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CardIconBadge(
          icon: icon,
          size: 34,
          iconSize: 18,
          background: iconBackground,
          foreground: iconForeground,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
