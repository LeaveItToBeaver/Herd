import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';
import 'package:herdapp/features/ui/customization/view/widgets/optimistic_slider_widget.dart';

class ComponentsTab extends ConsumerWidget {
  final UICustomizationModel customization;

  const ComponentsTab({
    super.key,
    required this.customization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Button Styles'),

          // Button shape
          CustomDropdown<String>(
            label: 'Button Shape',
            value: customization.componentStyles.primaryButton.shape,
            items: const ['rounded', 'pill', 'square'],
            onChanged: (value) => _updateButtonShape(ref, value!),
            keyValue: 'button_shape_dropdown',
          ),

          // Button radius
          OptimisticSlider<double>(
            provider: buttonShapeSliderProvider,
            label: 'Button Corner Radius',
            min: 0,
            max: 30,
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'Card Styles'),
          OptimisticSlider<double>(
            provider: cardRadiusSliderProvider,
            label: 'Card Corner Radius',
            min: 0,
            max: 30,
          ),
          CustomSlider(
            label: 'Card Elevation',
            value: customization.componentStyles.cardElevation,
            min: 0,
            max: 10,
            onChanged: (value) => _updateCardElevation(ref, value),
            keyValue: 'card_elevation_slider',
          ),

          const SizedBox(height: 24),

          const SectionHeader(title: 'Navigation Style'),
          SwitchListTile(
            key: const Key('floating_nav_switch'),
            title: const Text('Floating Navigation'),
            subtitle: const Text('Make navigation bar float above content'),
            value: customization.componentStyles.navigation.floating,
            onChanged: (value) => _updateNavigationFloating(ref, value),
          ),
          SwitchListTile(
            key: const Key('nav_labels_switch'),
            title: const Text('Show Labels'),
            subtitle: const Text('Display text labels in navigation'),
            value: customization.componentStyles.navigation.showLabels,
            onChanged: (value) => _updateNavigationLabels(ref, value),
          ),
        ],
      ),
    );
  }

  Future<void> _updateButtonShape(WidgetRef ref, String shape) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedButton =
        current.componentStyles.primaryButton.copyWith(shape: shape);
    final updatedStyles =
        current.componentStyles.copyWith(primaryButton: updatedButton);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateCardElevation(WidgetRef ref, double elevation) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedStyles =
        current.componentStyles.copyWith(cardElevation: elevation);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateNavigationFloating(WidgetRef ref, bool floating) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedNav =
        current.componentStyles.navigation.copyWith(floating: floating);
    final updatedStyles =
        current.componentStyles.copyWith(navigation: updatedNav);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateNavigationLabels(WidgetRef ref, bool showLabels) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedNav =
        current.componentStyles.navigation.copyWith(showLabels: showLabels);
    final updatedStyles =
        current.componentStyles.copyWith(navigation: updatedNav);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }
}
