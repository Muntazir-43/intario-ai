import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeUrl;
  final String afterUrl;
  final String? localBeforePath; // Optional local path for instant loading

  const BeforeAfterSlider({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
    this.localBeforePath,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> with SingleTickerProviderStateMixin {
  double _position = 0.5;
  late AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.65).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.65, end: 0.35).chain(CurveTween(curve: Curves.easeInOut)), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(_introController);

    animation.addListener(() {
      setState(() {
        _position = animation.value;
      });
    });

    // Start hint animation after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _introController.forward();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _updatePosition(Offset localPosition, double maxWidth) {
    if (_introController.isAnimating) _introController.stop();
    setState(() {
      _position = (localPosition.dx / maxWidth).clamp(0.02, 0.98);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: AppTheme.borderStrong(context),
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppTheme.cardRadius,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxW = constraints.maxWidth;
              final double maxH = constraints.maxHeight;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) => _updatePosition(details.localPosition, maxW),
                onTapDown: (details) => _updatePosition(details.localPosition, maxW),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ── Before image (Base layer) ──────────────────────
                    _SmartImage(
                      url: widget.beforeUrl,
                      localPath: widget.localBeforePath,
                    ),

                    // ── After image (Revealed layer) ───────────────────
                    ClipRect(
                      clipper: _SliderClipper(_position),
                      child: _SmartImage(url: widget.afterUrl),
                    ),

                    // ── Divider line ───────────────────────────────────
                    Positioned(
                      left: _position * maxW - 1,
                      top: 0,
                      bottom: 0,
                      width: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Handle circle ──────────────────────────────────
                    Positioned(
                      left: _position * maxW - 20,
                      top: maxH / 2 - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chevron_left_rounded,
                                  color: AppTheme.primary(context), size: 16),
                              Icon(Icons.chevron_right_rounded,
                                  color: AppTheme.primary(context), size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Before pill ────────────────────────────────────
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _Pill(
                        label: 'Before',
                        gradient: false,
                        isDark: isDark,
                      ),
                    ),

                    // ── After pill ─────────────────────────────────────
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _Pill(
                        label: 'After',
                        gradient: true,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double position;
  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    // Shows the After image on the right side of the slider
    return Rect.fromLTRB(size.width * position, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => oldClipper.position != position;
}

class _SmartImage extends StatelessWidget {
  final String url;
  final String? localPath;

  const _SmartImage({required this.url, this.localPath});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final baseColor = isDark ? AppTheme.dGlass : AppTheme.lDivider;

    // 1. Instant loading from local file if available
    if (localPath != null && localPath!.isNotEmpty) {
      final file = File(localPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: 1024,
        );
      }
    }

    // 2. Fallback to network
    if (url.isEmpty) {
      return Container(color: baseColor);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 1024,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: baseColor,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary(context),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: baseColor,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppTheme.textSecondary(context),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool gradient;
  final bool isDark;

  const _Pill({required this.label, required this.gradient, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient ? AppTheme.primaryGradient135(context) : null,
        color: gradient ? null : Colors.black.withValues(alpha: isDark ? 0.6 : 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
