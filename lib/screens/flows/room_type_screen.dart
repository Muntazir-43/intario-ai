import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/widgets/selection_card.dart';
import 'package:intario_ai/widgets/empty_state.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/models/wizard_state.dart';
import 'package:intario_ai/constants/room_types.dart';

class RoomTypeScreen extends ConsumerStatefulWidget {
  const RoomTypeScreen({super.key});

  @override
  ConsumerState<RoomTypeScreen> createState() => _RoomTypeScreenState();
}

class _RoomTypeScreenState extends ConsumerState<RoomTypeScreen> {
  String  _searchQuery = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredItems {
    if (_searchQuery.isEmpty) return RoomTypes.allItems;
    final q = _searchQuery.toLowerCase();
    return RoomTypes.all
        .where((r) => r['label']!.toLowerCase().contains(q))
        .toList();
  }

  void _onContinue() {
    final feature = ref.read(wizardProvider).feature;
    final fromConfirm = (GoRouterState.of(context).extra as Map?)?['fromConfirm'] ?? false;

    if (fromConfirm) {
      context.pop();
      return;
    }

    if (feature == FeatureType.styleTransfer) {
      context.push('/flow/confirm');
    } else {
      context.push('/flow/style');
    }
  }

  int _getStep(FeatureType? feature) {
    if (feature == FeatureType.styleTransfer) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final wizard   = ref.watch(wizardProvider);
    final filtered = _filteredItems;
    final isDark   = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FlowHeader(
            title:       'Select Room Type',
            currentStep: _getStep(wizard.feature),
            totalSteps:  wizard.totalSteps,
            onBack:      () => context.pop(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color:        AppTheme.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.border(context),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: AppTheme.textSecondary(context), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged:  (v) => setState(() => _searchQuery = v),
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary(context)),
                      decoration: InputDecoration(
                        hintText:       'Search room types...',
                        hintStyle:      TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
                        border:         InputBorder.none,
                        enabledBorder:  InputBorder.none,
                        focusedBorder:  InputBorder.none,
                        isDense:        true,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_searchQuery.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 15),
                      child: _SectionLabel('Recommended'),
                    ),
                    GridView.builder(
                      shrinkWrap:  true,
                      physics:     const NeverScrollableScrollPhysics(),
                      padding:     const EdgeInsets.only(bottom: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing:  8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount:   RoomTypes.recommendedItems.length,
                      itemBuilder: (_, i) {
                        final item = RoomTypes.recommendedItems[i];
                        final apiValue = RoomTypes.apiValue(item['label']!);
                        final isSelected = wizard.roomType == apiValue;
                        return SelectionCard(
                          label:      item['label']!,
                          emoji:      item['emoji']!,
                          isSelected: isSelected,
                          onTap: () => ref.read(wizardProvider.notifier).setRoomType(item['label']!),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 15),
                      child: _SectionLabel('All Room Types'),
                    ),
                  ],

                  if (filtered.isNotEmpty)
                    GridView.builder(
                      shrinkWrap:  true,
                      physics:     const NeverScrollableScrollPhysics(),
                      padding:     const EdgeInsets.only(bottom: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing:  8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount:   filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final apiValue = RoomTypes.apiValue(item['label']!);
                        final isSelected = wizard.roomType == apiValue;
                        return SelectionCard(
                          label:      item['label']!,
                          emoji:      item['emoji']!,
                          isSelected: isSelected,
                          onTap: () => ref.read(wizardProvider.notifier).setRoomType(item['label']!),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon:     Icons.search_off_rounded,
                        title:    'No Results',
                        subtitle: 'Try different keywords',
                      ),
                    ),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.bottomCenter,
                end:    Alignment.topCenter,
                colors: [
                  AppTheme.background(context),
                  AppTheme.background(context),
                  AppTheme.background(context).withValues(alpha: 0),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label:      'Continue',
              isDisabled: wizard.roomType == null,
              onTap:      _onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize:      12,
        fontWeight:    FontWeight.w500,
        color:         AppTheme.textSecondary(context),
        letterSpacing: 0.5,
      ),
    );
  }
}
