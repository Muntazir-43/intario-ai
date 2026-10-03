import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/before_after_slider.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/widgets/loading_overlay.dart';
import 'package:intario_ai/providers/projects_provider.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/project_model.dart';
import 'package:intario_ai/services/gallery_service.dart';
import 'package:intario_ai/utils/share_utils.dart';
import 'package:intario_ai/utils/haptics.dart';
import 'package:intario_ai/utils/enum_normalizer.dart';

class ProjectPreviewScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectPreviewScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectPreviewScreen> createState() => _ProjectPreviewScreenState();
}

class _ProjectPreviewScreenState extends ConsumerState<ProjectPreviewScreen> {
  bool _isDownloading = false;
  final GalleryService _galleryService = GalleryService();

  String _categoryLabel(String feature) {
    switch (feature) {
      case 'roomRedesign':    return 'Room';
      case 'virtualStaging':  return 'Staging';
      case 'styleTransfer':   return 'Style';
      case 'customPrompt':    return 'Custom';
      case 'bathroomRemodel': return 'Bathroom';
      case 'kitchenRemodel':  return 'Kitchen';
      case 'wallPaint':       return 'Wall';
      case 'cabinetColor':    return 'Cabinet';
      case 'frontYard':
      case 'backYard':
      case 'sideYard':        return 'Exterior';
      case 'seasonalDecor':   return 'Seasonal';
      default:                return feature;
    }
  }

  Future<void> _downloadImage(String url) async {
    if (url.isEmpty) return;
    AppHaptics.mediumTap();
    setState(() => _isDownloading = true);
    try {
      await _galleryService.saveNetworkImage(url);
      AppHaptics.success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image saved to Gallery'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppTheme.primary(context),
          ),
        );
      }
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _handleRegenerate(ProjectModel project) {
    AppHaptics.mediumTap();
    ref.read(wizardProvider.notifier).loadFromProject(project);
    context.go('/flow/upload');
  }

  void _handleShare(ProjectModel project) {
    AppHaptics.lightTap();
    ShareUtils.shareDesign(
      imageUrl: project.generatedImageUrl,
      feature: project.feature,
      metadata: project.metadata,
    );
  }

  static const _metaFields = [
    {'key': 'designStyle',     'label': 'Design Style',  'icon': Icons.palette_outlined},
    {'key': 'roomType',        'label': 'Room Type',      'icon': Icons.chair_outlined},
    {'key': 'colorScheme',     'label': 'Color Scheme',   'icon': Icons.color_lens_outlined},
    {'key': 'hexColor',        'label': 'Color',          'icon': Icons.circle},
    {'key': 'specialityDecor', 'label': 'Theme',          'icon': Icons.auto_awesome_outlined},
    {'key': 'gardenStyle',     'label': 'Garden Style',   'icon': Icons.park_outlined},
    {'key': 'prompt',          'label': 'Prompt',         'icon': Icons.edit_note_outlined},
    {'key': 'styleHint',       'label': 'Style Hint',     'icon': Icons.lightbulb_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final project = projects.cast<ProjectModel?>().firstWhere(
      (p) => p?.id == widget.projectId,
      orElse: () => null,
    );

    if (project == null) return const Scaffold(body: Center(child: Text('Project not found')));

    final meta = project.metadata;
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: LoadingOverlay(
        isLoading: _isDownloading,
        child: Column(
          children: [
            // ── Header ──
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
                  border: Border(bottom: BorderSide(color: AppTheme.border(context), width: 0.5)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        AppHaptics.lightTap();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/projects');
                        }
                      },
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
                          color: AppTheme.primary(context),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(project.title, style: AppTheme.screenTitle(context), overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(gradient: AppTheme.primaryGradient135(context), borderRadius: AppTheme.pillRadius),
                      child: Text(_categoryLabel(project.feature), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BeforeAfterSlider(
                      beforeUrl: project.originalImageUrl,
                      afterUrl: project.generatedImageUrl,
                    ),
                    const SizedBox(height: 20),

                    // Metadata Card
                    if (meta.isNotEmpty) ...[
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
                            Text('Generation Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary(context))),
                            const SizedBox(height: 14),
                            ...() {
                              final rows = <Widget>[];
                              final entries = _metaFields.where((f) => meta.containsKey(f['key']) && meta[f['key']] != null && meta[f['key']].toString().isNotEmpty).toList();
                              for (var i = 0; i < entries.length; i++) {
                                final field = entries[i];
                                final key = field['key'] as String;
                                var value = EnumNormalizer.formatDisplayValue(key, meta[key]?.toString());
                                if (key == 'prompt' && value.length > 150) {
                                  value = '${value.substring(0, 150)}...';
                                }
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
                      const SizedBox(height: 20),
                    ],

                    Center(
                      child: Text(
                        'Created ${DateFormat('MMM dd, yyyy').format(project.createdAt)}',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Download',
                            onTap: () => _downloadImage(project.generatedImageUrl)
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _handleShare(project),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary(context),
                                side: BorderSide(color: AppTheme.primary(context)),
                                shape: const RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                              ),
                              child: const Text('Share', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Regenerate Button
                    GestureDetector(
                      onTap: () => _handleRegenerate(project),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.card(context),
                          borderRadius: AppTheme.cardRadius,
                          border: Border.all(color: AppTheme.border(context)),
                          boxShadow: AppTheme.shadowLG(context),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded, color: AppTheme.primary(context), size: 18),
                              const SizedBox(width: 8),
                              Text('Regenerate This Design', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.primary(context))),
                            ],
                          ),
                        ),
                      ),
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
  const _MetaRow({required this.label, required this.value, required this.icon, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.divider(context), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary(context), size: 16),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: AppTheme.textPrimary(context)), maxLines: 5, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
