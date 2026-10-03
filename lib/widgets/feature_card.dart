import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;
  final String? badge;
  final bool isLocked;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    this.badge,
    this.isLocked = false,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData _iconFor(String title) {
    switch (title) {
      case 'Room Design':
        return Icons.chair_outlined;
      case 'Exterior Design':
        return Icons.villa_outlined;
      case 'Color Visualization':
        return Icons.palette_outlined;
      case 'Seasonal Design':
        return Icons.auto_awesome_outlined;
      case 'Premium AR':
        return Icons.view_in_ar_outlined;
      case 'AR Wall Color Visualizer':
        return Icons.palette_outlined;
      case 'AR Wall Decor Visualizer':
        return Icons.wallpaper_outlined;
      case 'AR Furniture Visualizer':
        return Icons.chair_outlined;
      default:
        return Icons.star_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        AppHaptics.mediumTap();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: double.infinity,
          height: 128,
          child: ClipRRect(
            borderRadius: AppTheme.cardRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background image ───────────────────────────────────────
                Opacity(
                  opacity: widget.isLocked ? 0.55 : 1.0,
                  child: Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: 600,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? AppTheme.dCard : AppTheme.lDivider,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppTheme.textSecondary(context),
                        size: 40,
                      ),
                    ),
                  ),
                ),

                // ── Gradient overlay ───────────────────────────────────────
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: isDark ? 0.85 : 0.70),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // ── Content row ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Icon container
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: AppTheme.iconRadius,
                        ),
                        child: Icon(
                          _iconFor(widget.title),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title + subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge or chevron
                      if (widget.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent(context),
                            borderRadius: AppTheme.pillRadius,
                          ),
                          child: Text(
                            widget.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.70),
                          size: 22,
                        ),
                    ],
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