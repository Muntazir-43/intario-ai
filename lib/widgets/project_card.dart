import 'package:flutter/material.dart';
import 'package:intario_ai/models/project_model.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/utils/haptics.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
  });

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  void _showMenu(BuildContext context) {
    AppHaptics.selection();
    final isDark = AppTheme.isDark(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark ? Border(top: BorderSide(color: AppTheme.dBorderSoft)) : null,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: AppTheme.divider(context),
                    borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: Icon(Icons.share_outlined, color: AppTheme.primary(context)),
                title: Text('Share Design', style: TextStyle(color: AppTheme.textPrimary(context))),
                onTap: () {
                  AppHaptics.lightTap();
                  Navigator.pop(context);
                  onShare();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.error),
                title: const Text('Delete Project',
                    style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  AppHaptics.lightTap();
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.shadowMD(context),
          color: AppTheme.card(context),
          border: isDark ? Border.all(color: AppTheme.dBorderSoft) : null,
        ),
        child: ClipRRect(
          borderRadius: AppTheme.cardRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ──
              Image.network(
                project.generatedImageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                      color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                      child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary(context),
                          )));
                },
                errorBuilder: (_, __, ___) => Container(
                  color: isDark ? AppTheme.dGlass : AppTheme.lDivider,
                  child: Icon(Icons.broken_image_outlined,
                      color: AppTheme.textSecondary(context)),
                ),
              ),

              // ── Gradient Overlay ──
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // ── More Button ──
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showMenu(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3), 
                        shape: BoxShape.circle),
                    child: const Icon(Icons.more_horiz_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),

              // ── Content ──
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Badge(label: project.displayRoom ?? 'Design'),
                        const Spacer(),
                        Text(
                          _timeAgo(project.createdAt),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2), 
          borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}
