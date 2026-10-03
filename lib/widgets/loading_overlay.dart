import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool   isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.45),
            child: Center(
              child: Container(
                width:  72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.dSecondaryBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
                  boxShadow: isDark 
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30)] 
                      : [const BoxShadow(color: Color(0x26000000), blurRadius: 32, offset: Offset(0, 8))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _GradientSpinner(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GradientSpinner extends StatefulWidget {
  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primary(context);
    final accent = AppTheme.accent(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.rotate(
        angle: _ctrl.value * 6.2832,
        child: CustomPaint(painter: _GradientArcPainter(primary, accent)),
      ),
    );
  }
}

class _GradientArcPainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _GradientArcPainter(this.primary, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final rect   = Offset.zero & size;
    final shader = SweepGradient(
      colors: [primary, accent, Colors.transparent],
      stops:  const [0.0, 0.65, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader     = shader
      ..strokeWidth = 3.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(2),
      0,
      5.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
