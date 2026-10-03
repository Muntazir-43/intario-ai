import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/feature_card.dart';
import 'package:intario_ai/widgets/bottom_nav_bar.dart';
import 'package:intario_ai/widgets/app_logo.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _features = [
    {
      'title':    'Room Design',
      'subtitle': 'Transform any room with AI',
      'imageUrl': 'assets/images/features/room_design.jpg',
      'route':    '/room-design',
      'feature':  FeatureType.roomRedesign,
    },
    {
      'title':    'Exterior Design',
      'subtitle': 'Reimagine your outdoor spaces',
      'imageUrl': 'assets/images/features/exterior_design.jpg',
      'route':    '/exterior-design',
      'feature':  FeatureType.frontYard,
    },
    {
      'title':    'Color Visualization',
      'subtitle': 'Experiment with colors instantly',
      'imageUrl': 'assets/images/features/color_visualization.jpg',
      'route':    '/color-visualization',
      'feature':  FeatureType.wallPaint,
    },
    {
      'title':    'Seasonal Design',
      'subtitle': 'Adapt your space to every season',
      'imageUrl': 'assets/images/features/seasonal_decor.jpg',
      'route':    '/flow/upload',
      'feature':  FeatureType.seasonalDecor,
    },
    {
      'title':    'Premium AR',
      'subtitle': 'Visualize designs in real-time',
      'imageUrl': 'assets/images/features/premium_ar.jpg',
      'route':    '/premium-ar',
      'isPremium': true,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark   = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned:          true,
                backgroundColor: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
                elevation:       0,
                toolbarHeight:   64,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        children: [
                          const AppLogo(height: 34),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: settings.isPro
                                  ? AppTheme.primaryGradient135(context)
                                  : null,
                              color: settings.isPro
                                  ? null
                                  : (isDark ? AppTheme.dGlass : AppTheme.lDivider),
                              borderRadius: AppTheme.pillRadius,
                              border: isDark && !settings.isPro
                                  ? Border.all(color: AppTheme.dBorderSoft)
                                  : null,
                            ),
                            child: Text(
                              settings.isPro ? 'PRO' : 'FREE',
                              style: TextStyle(
                                color: settings.isPro
                                    ? Colors.white
                                    : AppTheme.textSecondary(context),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 16), child: _HeroCarousel())),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text('Features', style: AppTheme.sectionHead(context)),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index.isOdd) return const SizedBox(height: 12);
                      final item = _features[index ~/ 2];
                      final isPremium = item['isPremium'] as bool? ?? false;
                      final isLocked = isPremium && !settings.isPro;

                      return FeatureCard(
                        title:    item['title'] as String,
                        subtitle: item['subtitle'] as String,
                        imageUrl: item['imageUrl'] as String,
                        badge:    isLocked ? 'PRO' : null,
                        isLocked: isLocked,
                        onTap: () {
                          if (isLocked) {
                            context.push('/settings');
                            return;
                          }
                          final feature = item['feature'] as FeatureType?;
                          if (feature != null) {
                            ref.read(wizardProvider.notifier).setFeature(feature);
                          }
                          context.push(item['route'] as String);
                        },
                      );
                    },
                    childCount: _features.length * 2 - 1,
                  ),
                ),
              ),
            ],
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _pageCtrl;
  late final Timer _timer;
  int _currentPage = 0;

  static const _slides = [
    {
      'title':    'Transform Your Space\nInstantly',
      'subtitle': 'AI-Powered Interior Design',
      'imageUrl': 'assets/images/features/Banner_1.jpg',
    },
    {
      'title':    'Redesign Any Room\nin Seconds',
      'subtitle': 'Professional Results, Zero Effort',
      'imageUrl': 'assets/images/features/Banner_2.jpg',
    },
    {
      'title':    'Bring Your Vision\nto Life',
      'subtitle': '50+ Design Styles Available',
      'imageUrl': 'assets/images/features/Banner_3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: _slides.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) {
          final slide = _slides[index];
          final isActive = index == _currentPage;

          return AnimatedScale(
            duration: const Duration(milliseconds: 400),
            scale: isActive ? 1 : 0.94,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: AppTheme.cardRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Image.asset(
                      slide['imageUrl']!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppTheme.card(context)),
                    ),

                    // Gradient overlay (Cinematic)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: isDark ? 0.75 : 0.55),
                            AppTheme.primary(context).withValues(alpha: 0.55),
                            AppTheme.accent(context).withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['subtitle']!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slides.length, (i) {
                              final active = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 26 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
