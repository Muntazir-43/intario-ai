import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/feature_card.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/utils/enum_normalizer.dart';

// ── Room Design Gateway ──────────────────────────────────────────────────────

class RoomDesignGateway extends ConsumerWidget {
  const RoomDesignGateway({super.key});

  static const _features = [
    {
      'title':    'Room Redesign',
      'subtitle': 'Transform any room into a new style',
      'imageUrl': 'assets/images/features/room_redesign.jpg',
      'feature':  FeatureType.roomRedesign,
    },
    {
      'title':    'Virtual Staging',
      'subtitle': 'Add furniture to empty rooms',
      'imageUrl': 'assets/images/features/virtual_staging.jpg',
      'feature':  FeatureType.virtualStaging,
    },
    {
      'title':    'Style Transfer',
      'subtitle': 'Apply different design styles',
      'imageUrl': 'assets/images/features/style_transfer.jpg',
      'feature':  FeatureType.styleTransfer,
    },
    {
      'title':    'Custom Prompt',
      'subtitle': 'Describe your dream design',
      'imageUrl': 'assets/images/features/custom_prompt.jpg',
      'feature':  FeatureType.customPrompt,
    },
    {
      'title':    'Bathroom Remodel',
      'subtitle': 'Redesign your bathroom',
      'imageUrl': 'assets/images/features/bathroom_remodel.jpg',
      'feature':  FeatureType.bathroomRemodel,
    },
    {
      'title':    'Kitchen Remodel',
      'subtitle': 'Transform your kitchen',
      'imageUrl': 'assets/images/features/kitchen_remodel.jpg',
      'feature':  FeatureType.kitchenRemodel,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
        elevation:       0,
        title: Text('Room Design', style: AppTheme.screenTitle(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary(context), size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.separated(
        padding:    const EdgeInsets.all(24),
        itemCount:  _features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item    = _features[i];
          final feature = item['feature'] as FeatureType;
          return FeatureCard(
            title:    item['title']    as String,
            subtitle: item['subtitle'] as String,
            imageUrl: item['imageUrl'] as String,
            onTap: () {
              ref.read(wizardProvider.notifier).setFeature(feature);
              context.push('/flow/upload');
            },
          );
        },
      ),
    );
  }
}

// ── Exterior Design Gateway ──────────────────────────────────────────────────

class ExteriorDesignGateway extends ConsumerWidget {
  const ExteriorDesignGateway({super.key});

  static const _yards = [
    {
      'title':    'Front Yard',
      'subtitle': 'Transform your home\'s entrance',
      'imageUrl': 'assets/images/features/front_yard.jpg',
      'feature':  FeatureType.frontYard,
      'yard':     EnumNormalizer.frontYard,
    },
    {
      'title':    'Back Yard',
      'subtitle': 'Create your perfect outdoor space',
      'imageUrl': 'assets/images/features/back_yard.jpg',
      'feature':  FeatureType.backYard,
      'yard':     EnumNormalizer.backYard,
    },
    {
      'title':    'Side Yard',
      'subtitle': 'Optimize every outdoor area',
      'imageUrl': 'assets/images/features/side_yard.jpg',
      'feature':  FeatureType.sideYard,
      'yard':     EnumNormalizer.sideYard,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
        elevation:       0,
        title: Text('Exterior Design', style: AppTheme.screenTitle(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary(context), size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.separated(
        padding:    const EdgeInsets.all(24),
        itemCount:  _yards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item    = _yards[i];
          final feature = item['feature'] as FeatureType;
          final yard    = item['yard']    as String;
          return FeatureCard(
            title:    item['title']    as String,
            subtitle: item['subtitle'] as String,
            imageUrl: item['imageUrl'] as String,
            onTap: () {
              ref.read(wizardProvider.notifier).setFeature(feature);
              ref.read(wizardProvider.notifier).setYardType(yard);
              context.push('/flow/upload');
            },
          );
        },
      ),
    );
  }
}

// ── Color Visualization Gateway ──────────────────────────────────────────────

class ColorVisualizationGateway extends ConsumerWidget {
  const ColorVisualizationGateway({super.key});

  static const _options = [
    {
      'title':    'Wall Paint',
      'subtitle': 'Visualize different wall colors',
      'imageUrl': 'assets/images/features/wall_paint.jpg',
      'feature':  FeatureType.wallPaint,
    },
    {
      'title':    'Kitchen Cabinet Color',
      'subtitle': 'Experiment with cabinet colors',
      'imageUrl': 'assets/images/features/cabinet_color.jpg',
      'feature':  FeatureType.cabinetColor,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
        elevation:       0,
        title: Text('Color Visualization', style: AppTheme.screenTitle(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary(context), size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.separated(
        padding:    const EdgeInsets.all(24),
        itemCount:  _options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item    = _options[i];
          final feature = item['feature'] as FeatureType;
          return FeatureCard(
            title:    item['title']    as String,
            subtitle: item['subtitle'] as String,
            imageUrl: item['imageUrl'] as String,
            onTap: () {
              ref.read(wizardProvider.notifier).setFeature(feature);
              context.push('/flow/upload');
            },
          );
        },
      ),
    );
  }
}
