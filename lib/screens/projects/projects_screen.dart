import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/project_card.dart';
import 'package:intario_ai/widgets/bottom_nav_bar.dart';
import 'package:intario_ai/widgets/empty_state.dart';
import 'package:intario_ai/providers/projects_provider.dart';
import 'package:intario_ai/models/project_model.dart';
import 'package:intario_ai/utils/haptics.dart';
import 'package:intario_ai/utils/share_utils.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Room', 'Exterior', 'Color', 'Seasonal'];

  List<ProjectModel> _applyFilters(List<ProjectModel> projects) {
    var result = projects;

    if (_selectedFilter != 'All') {
      result = result.where((p) {
        final f = p.feature.toLowerCase();
        switch (_selectedFilter) {
          case 'Room':
            return f.contains('room') ||
                f.contains('staging') ||
                f.contains('style') ||
                f.contains('prompt') ||
                f.contains('bathroom') ||
                f.contains('kitchen');
          case 'Exterior':
            return f.contains('yard');
          case 'Color':
            return f.contains('paint') || f.contains('cabinet');
          case 'Seasonal':
            return f.contains('seasonal');
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(q) ||
            (p.displayStyle ?? '').toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  void _shareProject(ProjectModel project) {
    AppHaptics.lightTap();
    ShareUtils.shareDesign(imageUrl: project.generatedImageUrl);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    AppHaptics.selection();
    final isDark = AppTheme.isDark(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackground(context),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary(context),
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.lightTap();
              Navigator.pop(context, false);
            },
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          TextButton(
            onPressed: () {
              AppHaptics.mediumTap();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(projectsProvider.notifier).deleteProject(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final filtered = _applyFilters(projects);
    final hasSearch = _searchQuery.isNotEmpty || _selectedFilter != 'All';
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background(context).withOpacity(isDark ? 0.85 : 0.92),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Projects',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Search bar
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.border(context),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                Icons.search_rounded,
                                color: AppTheme.textSecondary(context),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search projects...',
                                    hintStyle: TextStyle(
                                      color: AppTheme.textSecondary(context),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((filter) {
                              final active = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedFilter != filter) {
                                      AppHaptics.selection();
                                      setState(() => _selectedFilter = filter);
                                    }
                                  },
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutBack,
                                    scale: active ? 1.08 : 1.0,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutCubic,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: active
                                            ? AppTheme.primaryGradient135(context)
                                            : null,
                                        color: active ? null : (isDark ? AppTheme.dGlass : AppTheme.lDivider),
                                        borderRadius: BorderRadius.circular(999),
                                        border: isDark && !active
                                            ? Border.all(color: AppTheme.dBorderSoft)
                                            : null,
                                        boxShadow: active
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primary(context).withValues(alpha: isDark ? 0.15 : 0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Text(
                                        filter,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? Colors.white
                                              : AppTheme.textSecondary(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? hasSearch
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Results',
                            subtitle: 'Try a different search or filter',
                          )
                        : EmptyState(
                            icon: Icons.folder_open_rounded,
                            title: 'No Projects Yet',
                            subtitle: 'Your generated designs will appear here',
                            actionLabel: 'Start Designing',
                            onAction: () {
                              AppHaptics.mediumTap();
                              context.go('/');
                            },
                          )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final project = filtered[index];
                          return ProjectCard(
                            project: project,
                            onTap: () =>
                                context.push('/project/${project.id}'),
                            onShare: () => _shareProject(project),
                            onDelete: () =>
                                _confirmDelete(context, ref, project.id),
                          );
                        },
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
