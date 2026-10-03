import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/feature_card.dart';

class PremiumARScreen extends StatelessWidget {
  const PremiumARScreen({super.key});

  static const _arChannel = MethodChannel('com.intario_ai/ar_launcher');
  static const _wallColorPackage = 'com.Intario_Ai.arwallcolor';
  static const _wallDecorPackage = 'com.Intario_Ai.arwalldecor';
  static const _furniturePackage = 'com.Intario_Ai.ARFurnitur';

  static const _premiumFeatures = [
    {
      'title': 'AR Wall Color Visualizer',
      'subtitle': 'Experiment with wall colors in real-time',
      'imageUrl': 'assets/images/features/color_visualization.jpg',
    },
    {
      'title': 'AR Wall Decor Visualizer',
      'subtitle': 'Virtually place art frames and decor on your walls',
      'imageUrl': 'assets/images/features/room_design.jpg',
    },
    {
      'title': 'AR Furniture Visualizer',
      'subtitle': 'Position and scale 3D furniture pieces live',
      'imageUrl': 'assets/images/features/premium_ar.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primary(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Column(
        children: [
          // ───────── HEADER ─────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                        borderRadius: AppTheme.iconRadius,
                        border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Premium AR',
                    style: AppTheme.screenTitle(context),
                  ),
                ],
              ),
            ),
          ),

          // ───────── FEATURE CARDS ─────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              itemCount: _premiumFeatures.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final feature = _premiumFeatures[index];
                return FeatureCard(
                  title: feature['title']!,
                  subtitle: feature['subtitle']!,
                  imageUrl: feature['imageUrl']!,
                  onTap: () {
                    if (index == 0) {
                      _launchWallColorAR(context, primary);
                    } else if (index == 1) {
                      _launchWallDecorAR(context, primary);
                    } else if (index == 2) {
                      _launchFurnitureAR(context, primary);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWallColorAR(BuildContext context, Color primary) =>
      _launchARFeature(context, primary, 'AR Wall Color Visualizer', _wallColorPackage);

  Future<void> _launchWallDecorAR(BuildContext context, Color primary) =>
      _launchARFeature(context, primary, 'AR Wall Decor Visualizer', _wallDecorPackage);

  Future<void> _launchFurnitureAR(BuildContext context, Color primary) =>
      _launchARFeature(context, primary, 'AR Furniture Visualizer', _furniturePackage);

  Future<void> _launchARFeature(
    BuildContext context,
    Color primary,
    String title,
    String packageName,
  ) async {
    try {
      final bool isInstalled = await _arChannel.invokeMethod<bool>(
        'isAppInstalled',
        {'packageName': packageName},
      ) ?? false;

      if (!context.mounted) return;

      if (isInstalled) {
        final bool launched = await _arChannel.invokeMethod<bool>(
          'launchApp',
          {'packageName': packageName},
        ) ?? false;

        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to launch $title.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title is not installed on this device.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching AR: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
