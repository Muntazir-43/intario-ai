import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/before_after_slider.dart';
import 'package:intario_ai/widgets/loading_overlay.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/providers/settings_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/services/gallery_service.dart';
import 'package:intario_ai/utils/haptics.dart';
import 'package:intario_ai/utils/share_utils.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final bool _isSaving = false;
  bool _isSaved = false;
  bool _isDownloading = false;

  late final String _beforeUrl;
  late final String _afterUrl;
  late final String? _localBeforePath;
  late final WizardState _wizard;

  final GalleryService _galleryService = GalleryService();

  @override
  void initState() {
    super.initState();
    _wizard = ref.read(wizardProvider);
    _beforeUrl = _wizard.originalImageUrl ?? '';
    _afterUrl = _wizard.generatedImageUrl ?? '';
    _localBeforePath = _wizard.localInputPath;

    final autoSave = ref.read(settingsProvider).autoSave;
    if (autoSave) _isSaved = true;

    // Trigger success haptic on entry
    AppHaptics.success();

    if (autoSave) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Design saved to Gallery'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primary(context),
          ),
        );
      });
    }
  }

  Future<void> _downloadImage() async {
    if (_afterUrl.isEmpty) return;
    AppHaptics.mediumTap();
    setState(() => _isDownloading = true);
    try {
      await _galleryService.saveNetworkImage(_afterUrl);
      AppHaptics.success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image saved to Gallery'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.primary(context),
          ),
        );
      }
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save to Gallery: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _shareImage() {
    AppHaptics.lightTap();
    ShareUtils.shareDesign(
      imageUrl: _afterUrl,
      feature: _wizard.feature?.name,
      metadata: _wizard.metadata,
    );
  }

  void _onExit() {
    AppHaptics.lightTap();
    ref.read(wizardProvider.notifier).reset();
    context.go('/');
  }

  static const _metaFields = [
    {
      'key': 'designStyle',
      'label': 'Design Style',
      'icon': Icons.palette_outlined
    },
    {'key': 'roomType', 'label': 'Room Type', 'icon': Icons.chair_outlined},
    {
      'key': 'colorScheme',
      'label': 'Color Scheme',
      'icon': Icons.color_lens_outlined
    },
    {'key': 'hexColor', 'label': 'Color', 'icon': Icons.circle},
    {
      'key': 'specialityDecor',
      'label': 'Theme',
      'icon': Icons.auto_awesome_outlined
    },
    {'key': 'gardenStyle', 'label': 'Garden Style', 'icon': Icons.park_outlined},
    {
      'key': 'prompt',
      'label': 'Prompt',
      'icon': Icons.edit_note_outlined
    },
    {
      'key': 'styleHint',
      'label': 'Style Hint',
      'icon': Icons.lightbulb_outline_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: LoadingOverlay(
        isLoading: _isSaving || _isDownloading,
        child: Column(
          children: [
            // ── Header ──
            SafeArea(
              bottom: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
                  border: Border(
                      bottom: BorderSide(
                          color: AppTheme.border(context), width: 0.5)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _onExit,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                            borderRadius: AppTheme.iconRadius,
                            border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.primary(context), size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text('Your Design', style: AppTheme.screenTitle(context))),
                  ],
                ),
              ),
            ),
            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  children: [
                    BeforeAfterSlider(
                      beforeUrl: _beforeUrl,
                      afterUrl: _afterUrl,
                      localBeforePath: _localBeforePath,
                    ),
                    const SizedBox(height: 20),

                    // Generation Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: AppTheme.cardRadius,
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: AppTheme.shadowLG(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generation Details',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary(context))),
                          const SizedBox(height: 14),
                          ...() {
                            final rows = <Widget>[];
                            final metadata = _wizard.metadata;
                            final entries = _metaFields
                                .where((f) =>
                                    metadata.containsKey(f['key']) &&
                                    metadata[f['key']] != null)
                                .toList();
                            for (var i = 0; i < entries.length; i++) {
                              final field = entries[i];
                              final key = field['key'] as String;
                              var value = metadata[key].toString();
                              rows.add(_MetaRow(
                                label: field['label'] as String,
                                value: value,
                                icon: field['icon'] as IconData,
                                isLast: i == entries.length - 1,
                              ));
                            }
                            return rows;
                          }(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.6,
                      ),
                      children: [
                        _ActionButton(
                          icon: Icons.bookmark_rounded,
                          label: 'Saved',
                          gradient: [AppTheme.primary(context), AppTheme.accent(context)],
                          onTap: null, // Already saved
                        ),
                        _ActionButton(
                          icon: Icons.download_rounded,
                          label: _isDownloading ? 'Saving...' : 'Download',
                          gradient: [AppTheme.accent(context), AppTheme.primary(context)],
                          onTap: _downloadImage,
                        ),
                        _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          gradient: [
                            AppTheme.primary(context),
                            AppTheme.accent(context)
                          ],
                          onTap: _shareImage,
                        ),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Regenerate',
                          gradient: [
                            AppTheme.primary(context).withValues(alpha: 0.8),
                            AppTheme.primary(context)
                          ],
                          onTap: () {
                            AppHaptics.mediumTap();
                            context.go('/flow/upload');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;
  const _MetaRow(
      {required this.label,
      required this.value,
      required this.icon,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: AppTheme.divider(context), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary(context), size: 16),
          const SizedBox(width: 12),
          SizedBox(
              width: 100,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary(context)))),
          Expanded(
              child: Text(value,
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.gradient,
      this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
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

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: (_) => !disabled ? _controller.reverse() : null,
      onTapUp: (_) => !disabled ? _controller.forward() : null,
      onTapCancel: () => !disabled ? _controller.forward() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: disabled ? 0.7 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowLG(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                Text(widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
