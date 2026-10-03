import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class GeneratingScreen extends ConsumerStatefulWidget {
  const GeneratingScreen({super.key});

  @override
  ConsumerState<GeneratingScreen> createState() =>
      _GeneratingScreenState();
}

class _GeneratingScreenState
    extends ConsumerState<GeneratingScreen> {
  int _currentStep = 0;

  Timer? _stepTimer;

  static const _steps = [
    'Uploading image',
    'Analyzing room',
    'Processing style',
    'Rendering design',
  ];

  static const _subtitles = [
    'Preparing your image for AI enhancement',
    'Understanding room structure and layout',
    'Applying selected aesthetics and materials',
    'Generating your final photorealistic design',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void _startGeneration() {
    _stepTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_currentStep < _steps.length - 1) {
          AppHaptics.selection();

          setState(() {
            _currentStep++;
          });

          if (_currentStep == _steps.length - 1) {
            Future.delayed(
              const Duration(milliseconds: 120),
                  () => AppHaptics.lightTap(),
            );
          }
        } else {
          timer.cancel();
        }
      },
    );

    ref.read(wizardProvider.notifier).generate().then((_) async {
      _stepTimer?.cancel();

      if (!mounted) return;

      final error = ref.read(wizardProvider).error;

      if (error != null) {
        context.push(
          '/error?message=${Uri.encodeComponent(error)}',
        );
        return;
      }

      setState(() {
        _currentStep = _steps.length - 1;
      });

      AppHaptics.success();

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      context.push('/flow/result');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);
    final accent = AppTheme.accent(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.background(context),
        body: Stack(
          children: [
            // ───────────────── Background Glow (Subtle & Neutral) ─────────────────

            Positioned(
              top: -140,
              left: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withValues(alpha: isDark ? 0.08 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -160,
              right: -140,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: isDark ? 0.06 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Column(
                      children: [
                        // ───────────────── Spinner ─────────────────

                        SizedBox(
                          width: 170,
                          height: 170,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      primary.withValues(alpha: isDark ? 0.10 : 0.14),
                                      accent.withValues(alpha: isDark ? 0.04 : 0.04),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              _RotatingArc(primary: primary, accent: accent),

                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.card(context),
                                  border: Border.all(
                                    color: AppTheme.border(context),
                                  ),
                                  boxShadow: AppTheme.shadowLG(context),
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: primary,
                                  size: 34,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 38),

                        // ───────────────── Title ─────────────────

                        ShaderMask(
                          shaderCallback: (bounds) {
                            return AppTheme.primaryGradient(context)
                                .createShader(bounds);
                          },
                          child: const Text(
                            'Transforming your space',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          child: Text(
                            _subtitles[_currentStep],
                            key: ValueKey(_currentStep),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 42),

                        // ───────────────── Step Cards ─────────────────

                        Column(
                          children: List.generate(
                            _steps.length,
                                (i) {
                              final status =
                              i < _currentStep
                                  ? 'complete'
                                  : i == _currentStep
                                  ? 'active'
                                  : 'pending';

                              return Padding(
                                padding:
                                const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                child: _StepItem(
                                  index: i,
                                  label: _steps[i],
                                  status: status,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ROTATING ARC
// ─────────────────────────────────────────────────────────────

class _RotatingArc extends StatefulWidget {
  final Color primary;
  final Color accent;
  const _RotatingArc({required this.primary, required this.accent});

  @override
  State<_RotatingArc> createState() =>
      _RotatingArcState();
}

class _RotatingArcState extends State<_RotatingArc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Transform.rotate(
          angle: _ctrl.value * math.pi * 2,
          child: CustomPaint(
            size: const Size(170, 170),
            painter: _ArcPainter(widget.primary, widget.accent),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _ArcPainter(this.primary, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final shader = SweepGradient(
      colors: [
        primary,
        accent,
        Colors.transparent,
      ],
      stops: const [0.0, 0.68, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(4),
      0,
      5.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}

// ─────────────────────────────────────────────────────────────
// STEP ITEM
// ─────────────────────────────────────────────────────────────

class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final String status;

  const _StepItem({
    required this.index,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final isComplete = status == 'complete';
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? null
            : isComplete
                ? AppTheme.card(context)
                : AppTheme.card(context).withValues(alpha: isDark ? 0.4 : 0.32),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  primary.withValues(alpha: isDark ? 0.12 : 0.10),
                  AppTheme.accent(context).withValues(alpha: isDark ? 0.08 : 0.08),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? primary.withValues(alpha: isDark ? 0.4 : 0.34)
              : AppTheme.border(context),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.05 : 0.10),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // ───────────────── Leading ─────────────────

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isComplete
                  ? AppTheme.primaryGradient135(context)
                  : null,
              color: isComplete
                  ? null
                  : isActive
                      ? Colors.transparent
                      : (isDark ? AppTheme.dGlass : AppTheme.lDivider),
              border: isActive
                  ? Border.all(
                      color: primary,
                      width: 2,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: isComplete
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? primary : AppTheme.textSecondary(context),
                    ),
                  ),
          ),

          const SizedBox(width: 14),

          // ───────────────── Label ─────────────────

          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive || isComplete
                    ? AppTheme.textPrimary(context)
                    : AppTheme.textSecondary(context),
              ),
              child: Text(label),
            ),
          ),

          // ───────────────── Status ─────────────────

          if (isActive) const _PulseDot(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PULSE DOT
// ─────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() =>
      _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.7,
      end: 1.35,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.accent(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
