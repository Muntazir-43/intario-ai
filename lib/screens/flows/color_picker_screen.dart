import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/utils/hex_validator.dart';
import 'package:intario_ai/utils/haptics.dart';

class ColorPickerScreen extends ConsumerStatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  ConsumerState<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends ConsumerState<ColorPickerScreen> {
  double _hue = 0.0;
  double _saturation = 0.0;
  double _brightness = 1.0;
  late final TextEditingController _hexCtrl;
  String? _hexError;

  static const _quickPicks = [
    '#FFFFFF',
    '#FFF8F0',
    '#FFE8D0',
    '#E8F5E9',
    '#E3F2FD',
    '#F3E5F5',
    '#000000',
    '#6B4226',
    '#607D8B',
    '#1565C0',
    '#2E7D32',
    '#C62828',
    '#FF6B6B',
    '#FFD93D',
  ];

  @override
  void initState() {
    super.initState();
    final initialHex = ref.read(wizardProvider).selectedHexColor ?? '#FFFFFF';
    _hexCtrl = TextEditingController(text: initialHex);
    _parseHexToHSV(initialHex, updateState: false);
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _saturation, _brightness).toColor();

  String get _currentHex {
    final c = _currentColor;
    final r = c.red.toRadixString(16).padLeft(2, '0');
    final g = c.green.toRadixString(16).padLeft(2, '0');
    final b = c.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  void _onHexChanged(String val) {
    final trimmed = val.trim();
    if (HexValidator.isValid(trimmed)) {
      setState(() => _hexError = null);
      _parseHexToHSV(trimmed);
      ref.read(wizardProvider.notifier).setHexColor(trimmed);
    } else {
      setState(() => _hexError = 'Enter a valid hex color');
    }
  }

  void _parseHexToHSV(String hex, {bool updateState = true}) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return;
    final r = int.parse(cleaned.substring(0, 2), radix: 16);
    final g = int.parse(cleaned.substring(2, 4), radix: 16);
    final b = int.parse(cleaned.substring(4, 6), radix: 16);
    final hsv = HSVColor.fromColor(Color.fromARGB(255, r, g, b));

    if (updateState) {
      setState(() {
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _brightness = hsv.value;
      });
    } else {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _brightness = hsv.value;
    }
  }

  void _syncHexFromHSV() {
    final hex = _currentHex;
    _hexCtrl.text = hex;
    setState(() => _hexError = null);
    ref.read(wizardProvider.notifier).setHexColor(hex);
  }

  void _setFromQuickPick(String hex) {
    AppHaptics.selection();
    _hexCtrl.text = hex;
    _onHexChanged(hex);
  }

  void _onContinue() {
    if (_hexError != null) return;
    ref.read(wizardProvider.notifier).setHexColor(_currentHex);

    final fromConfirm =
        (GoRouterState.of(context).extra as Map?)?['fromConfirm'] ?? false;
    if (fromConfirm) {
      context.pop();
    } else {
      context.push('/flow/confirm');
    }
  }

  String _titleFor(FeatureType? feature) => feature == FeatureType.cabinetColor
      ? 'Choose Cabinet Color'
      : 'Choose Wall Color';

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(wizardProvider);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FlowHeader(
            title: _titleFor(wizard.feature),
            currentStep: 2,
            totalSteps:  wizard.totalSteps,
            onBack: () {
              AppHaptics.lightTap();
              context.pop();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
                            blurRadius: 22,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: _currentColor.withValues(alpha:
                              _brightness > 0.85 ? 0.22 : 0.40,
                            ),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                        border: isDark ? Border.all(color: AppTheme.dBorderStrong) : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'HEX Color',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: TextField(
                      controller: _hexCtrl,
                      onChanged: _onHexChanged,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'monospace',
                          color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText: '#FFFFFF',
                        hintStyle: TextStyle(color: AppTheme.textSecondary(context)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  if (_hexError != null) ...[
                    const SizedBox(height: 4),
                    Text(_hexError!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.error)),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Quick picks',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickPicks.map((hex) {
                      final isSelected =
                          _currentHex.toLowerCase() == hex.toLowerCase();
                      return GestureDetector(
                        onTap: () => _setFromQuickPick(hex),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 150),
                          scale: isSelected ? 1.15 : 1.0,
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  'FF${hex.replaceFirst('#', '')}',
                                  radix: 16)),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary(context)
                                    : AppTheme.border(context),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected ? AppTheme.shadowMD(context) : [],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Color',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                  ),
                  const SizedBox(height: 10),
                  _SaturationBrightnessBox(
                    hue: _hue,
                    saturation: _saturation,
                    brightness: _brightness,
                    onChanged: (s, b) {
                      setState(() {
                        _saturation = s;
                        _brightness = b;
                      });
                      _syncHexFromHSV();
                    },
                  ),
                  const SizedBox(height: 16),
                  _HueSlider(
                    hue: _hue,
                    onChanged: (h) {
                      setState(() => _hue = h);
                      _syncHexFromHSV();
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label: 'Continue',
              isDisabled: _hexError != null,
              onTap: _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaturationBrightnessBox extends StatelessWidget {
  final double hue;
  final double saturation;
  final double brightness;
  final void Function(double s, double b) onChanged;

  const _SaturationBrightnessBox({
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.onChanged,
  });

  void _handleInteraction(Offset pos, double width, double height) {
    final s = (pos.dx / width).clamp(0.0, 1.0);
    final b = (1.0 - pos.dy / height).clamp(0.0, 1.0);
    onChanged(s, b);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        const h = 200.0;
        final thumbX = saturation * w;
        final thumbY = (1.0 - brightness) * h;

        return GestureDetector(
          onPanStart: (_) => AppHaptics.selection(),
          onPanUpdate: (d) {
            _handleInteraction(d.localPosition, w, h);
          },
          onTapDown: (d) {
            AppHaptics.selection();
            _handleInteraction(d.localPosition, w, h);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(w, h),
                    painter: _SBPainter(hue),
                  ),
                  Positioned(
                    left: thumbX - 11,
                    top: thumbY - 11,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SBPainter extends CustomPainter {
  final double hue;
  const _SBPainter(this.hue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final satPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor()],
      ).createShader(rect);
    canvas.drawRect(rect, satPaint);

    final briPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect);
    canvas.drawRect(rect, briPaint);
  }

  @override
  bool shouldRepaint(_SBPainter old) => old.hue != hue;
}

class _HueSlider extends StatelessWidget {
  final double hue;
  final void Function(double) onChanged;

  const _HueSlider({required this.hue, required this.onChanged});

  void _handleInteraction(Offset pos, double width) {
    final h = (pos.dx / width * 360).clamp(0.0, 360.0);
    onChanged(h);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        const h = 28.0;
        final thumbX = (hue / 360.0) * w;

        return GestureDetector(
          onPanStart: (_) => AppHaptics.selection(),
          onPanUpdate: (d) {
            _handleInteraction(d.localPosition, w);
          },
          onTapDown: (d) {
            AppHaptics.selection();
            _handleInteraction(d.localPosition, w);
          },
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    size: Size(w, h),
                    painter: _HuePainter(),
                  ),
                ),
                Positioned(
                  left: (thumbX - 3).clamp(0.0, w - 6),
                  top: 0,
                  child: Container(
                    width: 6,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HuePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: List.generate(
            7, (i) => HSVColor.fromAHSV(1.0, i * 60.0, 1.0, 1.0).toColor()),
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
