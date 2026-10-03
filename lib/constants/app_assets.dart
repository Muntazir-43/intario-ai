class AppAssets {
  AppAssets._();

  static const String logoLight = 'assets/logo_icon/Intario_Logo.png';
  static const String logoDark = 'assets/logo_icon/Intario_Logo_B.png';

  // Helper to get logo based on brightness
  static String logo(bool isDark) => isDark ? logoDark : logoLight;
}
