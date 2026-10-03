import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intario_ai/navigation/app_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/providers/settings_provider.dart';

class IntarioApp extends ConsumerWidget {
  const IntarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Intario AI',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Router configuration
      routerConfig: router,

      // CRITICAL: Ensure the initial canvas is WHITE during the handover.
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: child,
        );
      },
    );
  }
}
