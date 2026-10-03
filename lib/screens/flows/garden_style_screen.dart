import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/flow_header.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/widgets/selection_card.dart';
import 'package:intario_ai/widgets/empty_state.dart';
import 'package:intario_ai/providers/wizard_provider.dart';
import 'package:intario_ai/constants/garden_styles.dart';

class GardenStyleScreen extends ConsumerStatefulWidget {
  const GardenStyleScreen({super.key});

  @override
  ConsumerState<GardenStyleScreen> createState() => _GardenStyleScreenState();
}

class _GardenStyleScreenState extends ConsumerState<GardenStyleScreen> {
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
    if (_searchQuery.isEmpty) return GardenStyles.allItems;
    final q = _searchQuery.toLowerCase();
    return GardenStyles.all
        .where((g) => g['label']!.toLowerCase().contains(q))
        .toList();
  }

  void _onContinue() {
    final fromConfirm = (GoRouterState.of(context).extra as Map?)?['fromConfirm'] ?? false;
    if (fromConfirm) {
      context.pop();
    } else {
      context.push('/flow/confirm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizard   = ref.watch(wizardProvider);
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor:            AppTheme.background(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          FlowHeader(
            title:       'Choose Garden Style',
            currentStep: 2,
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
                        hintText:       'Search garden styles...',
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
                        mainAxisSpacing:  10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount:   GardenStyles.recommendedItems.length,
                      itemBuilder: (_, i) {
                        final item = GardenStyles.recommendedItems[i];
                        final apiValue = GardenStyles.apiValue(item['label']!);
                        final isSelected = wizard.gardenStyle == apiValue;
                        return SelectionCard(
                          label:      item['label']!,
                          imageUrl:   item['image']!,
                          isSelected: isSelected,
                          onTap: () => ref.read(wizardProvider.notifier).setGardenStyle(item['label']!),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 15),
                      child: _SectionLabel('All Garden Styles'),
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
                        mainAxisSpacing:  10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount:   filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final apiValue = GardenStyles.apiValue(item['label']!);
                        final isSelected = wizard.gardenStyle == apiValue;
                        return SelectionCard(
                          label:      item['label']!,
                          imageUrl:   item['image']!,
                          isSelected: isSelected,
                          onTap: () => ref.read(wizardProvider.notifier).setGardenStyle(item['label']!),
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
              gradient: AppTheme.ctaScrimGradient(context),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: GradientButton(
              label:      'Continue',
              isDisabled: wizard.gardenStyle == null,
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
