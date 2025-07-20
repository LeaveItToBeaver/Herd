import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';
import 'package:herdapp/features/ui/customization/view/widgets/theme_tab_widget.dart';
import 'package:herdapp/features/ui/customization/view/widgets/profile_tab_widget.dart';
import 'package:herdapp/features/ui/customization/view/widgets/components_tab_widget.dart';
import 'package:herdapp/features/ui/customization/view/widgets/layout_tab_widget.dart';
import 'package:herdapp/features/ui/customization/view/widgets/advanced_tab_widget.dart';

class UICustomizationScreen extends ConsumerStatefulWidget {
  const UICustomizationScreen({super.key});

  @override
  ConsumerState<UICustomizationScreen> createState() =>
      _UICustomizationScreenState();
}

class _UICustomizationScreenState extends ConsumerState<UICustomizationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizationAsync = ref.watch(uiCustomizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your Experience'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Theme'),
            Tab(text: 'Profile'),
            Tab(text: 'Components'),
            Tab(text: 'Layout'),
            Tab(text: 'Advanced'),
          ],
        ),
        actions: [
          // Reset button
          IconButton(
            key: const Key('reset_button'),
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to minimal theme',
            onPressed: () =>
                ResetDialog.show(context, () => _applyPreset('minimal')),
          ),
          // Preview button
          IconButton(
            key: const Key('preview_button'),
            icon: const Icon(Icons.preview),
            tooltip: 'Preview changes',
            onPressed: () => _showPreview(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Warning banner
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This feature is experimental and work in progress. Some options may not work as expected.',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: customizationAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      key: const Key('retry_button'),
                      onPressed: () {
                        // Retry loading
                        ref.invalidate(uiCustomizationProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (customization) {
                if (customization == null) {
                  return const Center(
                    child: Text('Please sign in to customize your experience'),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(fontScaleSliderProvider.notifier)
                      .updatePersistedValue(
                        customization.typography.fontScaleFactor,
                      );
                  ref
                      .read(shadowIntensitySliderProvider.notifier)
                      .updatePersistedValue(
                          customization.appTheme.shadowIntensity);
                  ref
                      .read(cardRadiusSliderProvider.notifier)
                      .updatePersistedValue(
                          customization.componentStyles.cardBorderRadius);
                  ref
                      .read(gridColumnsSliderProvider.notifier)
                      .updatePersistedValue(
                          customization.layoutPreferences.gridColumns);
                  ref
                      .read(buttonShapeSliderProvider.notifier)
                      .updatePersistedValue(
                          customization.componentStyles.buttonBorderRadius);
                });

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ThemeTab(customization: customization),
                    ProfileTab(customization: customization),
                    ComponentsTab(customization: customization),
                    LayoutTab(customization: customization),
                    AdvancedTab(customization: customization),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyPreset(String presetId) {
    ref.read(uiCustomizationProvider.notifier).applyPreset(presetId);
  }

  void _showPreview() {
    // Navigate to a preview screen or show a dialog with preview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview functionality coming soon!')),
    );
  }
}
