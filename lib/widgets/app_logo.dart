import 'package:flutter/material.dart';
import 'package:intario_ai/constants/app_assets.dart';
import 'package:intario_ai/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final String assetPath = AppAssets.logo(isDark);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Image.asset(
        assetPath,
        key: ValueKey(assetPath),
        height: height,
        width: width,
        fit: fit,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        cacheWidth: 300,
      ),
    );
  }
}
