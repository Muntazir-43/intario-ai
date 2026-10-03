import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── LIGHT PALETTE (Existing Refined) ──────────────────────────────────────
  static const Color lPrimary      = Color(0xFF1B3EBF);
  static const Color lAccent       = Color(0xFF00C9A7);
  static const Color lBackground   = Color(0xFFF8F9FF);
  static const Color lSecondaryBg  = Color(0xFFFFFFFF);
  static const Color lCard         = Color(0xFFFFFFFF);
  static const Color lTextPrimary  = Color(0xFF0D0F1A);
  static const Color lTextSecondary = Color(0xFF6B7280);
  static const Color lTextMuted     = Color(0xFF9CA3AF);
  static const Color lBorder       = Color(0xFFE5E7EB);
  static const Color lDivider      = Color(0xFFF1F2F6);

  // ── DARK PALETTE (Premium Cinematic) ──────────────────────────────────────
  static const Color dPrimary      = Color(0xFF4A6CF7);
  static const Color dAccent       = Color(0xFF00D7B6);
  static const Color dBackground   = Color(0xFF0E1116);
  static const Color dSecondaryBg  = Color(0xFF131720);
  static Color dGlass              = Colors.white.withValues(alpha: 0.04);
  static Color dCard               = Colors.white.withValues(alpha: 0.06);
  static Color dElevated           = Colors.white.withValues(alpha: 0.08);
  static Color dBorderSoft         = Colors.white.withValues(alpha: 0.10);
  static Color dBorderStrong       = Colors.white.withValues(alpha: 0.16);
  static const Color dTextPrimary  = Color(0xFFFAFAFB);
  static const Color dTextSecondary = Color(0xFFB7BCC9);
  static const Color dTextMuted     = Color(0xFF7C8596);
  static Color dDivider            = Colors.white.withValues(alpha: 0.06);

  // ── Status Colors ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFF87171);

  // ── Semantic Getters ───────────────────────────────────────────────────────
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color primary(BuildContext context) => isDark(context) ? dPrimary : lPrimary;
  static Color accent(BuildContext context)  => isDark(context) ? dAccent : lAccent;
  
  static Color background(BuildContext context) => isDark(context) ? dBackground : lBackground;
  static Color secondaryBackground(BuildContext context) => isDark(context) ? dSecondaryBg : lSecondaryBg;
  
  static Color card(BuildContext context) => isDark(context) ? dSecondaryBg : lCard;
  static Color glassSurface(BuildContext context) => isDark(context) ? dGlass : lCard;
  static Color elevatedCard(BuildContext context) => isDark(context) ? dElevated : lCard;
  
  static Color textPrimary(BuildContext context) => isDark(context) ? dTextPrimary : lTextPrimary;
  static Color textSecondary(BuildContext context) => isDark(context) ? dTextSecondary : lTextSecondary;
  static Color mutedText(BuildContext context) => isDark(context) ? dTextMuted : lTextMuted;
  
  static Color border(BuildContext context) => isDark(context) ? dBorderSoft : lBorder;
  static Color borderStrong(BuildContext context) => isDark(context) ? dBorderStrong : lBorder;
  static Color divider(BuildContext context) => isDark(context) ? dDivider : lDivider;

  // ── Gradients ────────────────────────────────────────────────────────────────
  static LinearGradient primaryGradient(BuildContext context) => LinearGradient(
    begin: Alignment.centerLeft,
    end:   Alignment.centerRight,
    colors: [primary(context), accent(context)],
  );

  static LinearGradient primaryGradient135(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [primary(context), accent(context)],
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end:   Alignment.centerRight,
    colors: [Color(0xB3000000), Color(0x00000000)],
  );

  static LinearGradient ctaScrimGradient(BuildContext context) => LinearGradient(
    begin: Alignment.bottomCenter,
    end:   Alignment.topCenter,
    colors: [background(context), background(context), Colors.transparent],
  );

  // ── Border Radius ────────────────────────────────────────────────────────────
  static const double radiusXL  = 24.0; 
  static const double radiusLG  = 16.0; 
  static const double radiusMD  = 12.0; 
  static const double radiusSM  =  8.0; 
  static const double radiusPill = 999.0;

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius inputRadius  = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius iconRadius   = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius pillRadius   = BorderRadius.all(Radius.circular(radiusPill));

  // ── Spacing ──────────────────────────────────────────────────────────────────
  static const double screenPadding  = 24.0;
  static const double cardPadding    = 20.0;
  static const double sectionGap     = 16.0;
  static const double itemGap        = 12.0;
  static const double ctaBottomPad   = 24.0;

  static const EdgeInsets screenInsets = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  // ── Typography ───────────────────────────────────────────────────────────────
  static TextStyle heroTitle(BuildContext context) => TextStyle(
    fontSize: 30, fontWeight: FontWeight.w500,
    color: dTextPrimary, height: 1.2,
  );

  static TextStyle screenTitle(BuildContext context) => TextStyle(
    fontSize: 20, fontWeight: FontWeight.w500, color: textPrimary(context),
  );

  static TextStyle sectionHead(BuildContext context) => TextStyle(
    fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary(context),
  );

  static TextStyle cardTitle(BuildContext context) => TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary(context),
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary(context),
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary(context),
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary(context),
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white,
  );

  static TextStyle labelMuted(BuildContext context) => TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: textSecondary(context),
    letterSpacing: 0.5,
  );

  // ── Shadows ──────────────────────────────────────────────────────────────────
  static List<BoxShadow> shadowMD(BuildContext context) => [
    BoxShadow(
      color: isDark(context) ? Colors.black.withValues(alpha: 0.4) : const Color(0x14000000), 
      blurRadius: 8, 
      offset: const Offset(0, 4)
    ),
  ];

  static List<BoxShadow> shadowLG(BuildContext context) => [
    BoxShadow(
      color: isDark(context) ? Colors.black.withValues(alpha: 0.5) : const Color(0x1A000000), 
      blurRadius: 16, 
      offset: const Offset(0, 4)
    ),
  ];

  static List<BoxShadow> shadowPrimary(BuildContext context) => [
    BoxShadow(
      color: primary(context).withValues(alpha: isDark(context) ? 0.15 : 0.30),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primaryColor = isDark ? dPrimary : lPrimary;
    final Color accentColor  = isDark ? dAccent : lAccent;
    final Color bgColor      = isDark ? dBackground : lBackground;
    final Color cardColor    = isDark ? dSecondaryBg : lCard;
    final Color txtPrimary   = isDark ? dTextPrimary : lTextPrimary;
    final Color txtSecondary = isDark ? dTextSecondary : lTextSecondary;
    final Color borderColor  = isDark ? dBorderSoft : lBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:   primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        surface:   cardColor,
        onSurface: txtPrimary,
        error:     error,
        onError:   Colors.white,
      ),
      scaffoldBackgroundColor: bgColor,
      dividerColor: isDark ? dDivider : lDivider,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w500, color: txtPrimary,
        ),
        iconTheme: IconThemeData(color: txtPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: txtSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: buttonLabel,
          elevation: 0,
        ),
      ),
    );
  }
}
