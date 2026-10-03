import 'package:flutter/material.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isDisabled || widget.isLoading;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: disabled
            ? null
            : () {
                AppHaptics.mediumTap();
                widget.onTap?.call();
              },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient135(context),
              borderRadius: AppTheme.buttonRadius,
              boxShadow: disabled ? [] : AppTheme.shadowPrimary(context),
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(widget.label, style: AppTheme.buttonLabel),
          ),
        ),
      ),
    );
  }
}
