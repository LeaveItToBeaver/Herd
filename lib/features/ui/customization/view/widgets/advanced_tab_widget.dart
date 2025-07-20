import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';
import 'package:herdapp/features/ui/customization/view/widgets/optimistic_slider_widget.dart';

class AdvancedTab extends ConsumerWidget {
  final UICustomizationModel customization;

  const AdvancedTab({
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
          const SectionHeader(title: 'Typography'),
          CustomDropdown<String>(
            label: 'Primary Font',
            value: customization.typography.primaryFont,
            items: const [
              'Roboto',
              'Inter',
              'Open Sans',
              'Lato',
              'Montserrat',
              'Playfair Display'
            ],
            onChanged: (value) => _updateFont(ref, value!),
            keyValue: 'font_dropdown',
          ),
          OptimisticSlider<double>(
            provider: fontScaleSliderProvider,
            label: 'Font Scale',
            min: 0.8,
            max: 1.5,
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Animations'),
          SwitchListTile(
            key: const Key('animations_enabled_switch'),
            title: const Text('Enable Animations'),
            subtitle: const Text('Turn off for better performance'),
            value: customization.animationSettings.enableAnimations,
            onChanged: (value) => _updateAnimationEnabled(ref, value),
          ),
          if (customization.animationSettings.enableAnimations) ...[
            CustomDropdown<String>(
              label: 'Animation Speed',
              value: customization.animationSettings.speed,
              items: const ['slow', 'normal', 'fast', 'instant'],
              onChanged: (value) => _updateAnimationSpeed(ref, value!),
              keyValue: 'animation_speed_dropdown',
            ),
            SwitchListTile(
              key: const Key('page_transitions_switch'),
              title: const Text('Page Transitions'),
              value: customization.animationSettings.enablePageTransitions,
              onChanged: (value) =>
                  _updateAnimationOption(ref, 'enablePageTransitions', value),
            ),
            SwitchListTile(
              key: const Key('hover_effects_switch'),
              title: const Text('Hover Effects'),
              value: customization.animationSettings.enableHoverEffects,
              onChanged: (value) =>
                  _updateAnimationOption(ref, 'enableHoverEffects', value),
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader(title: 'Import/Export'),
          Row(
            children: [
              ElevatedButton.icon(
                key: const Key('export_theme_button'),
                icon: const Icon(Icons.file_download),
                label: const Text('Export Theme'),
                onPressed: () => _exportTheme(context),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                key: const Key('import_theme_button'),
                icon: const Icon(Icons.file_upload),
                label: const Text('Import Theme'),
                onPressed: () => _importTheme(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateFont(WidgetRef ref, String font) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedTypo = current.typography.copyWith(primaryFont: font);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateTypography(updatedTypo);
  }

  Future<void> _updateAnimationEnabled(WidgetRef ref, bool enabled) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedAnim =
        current.animationSettings.copyWith(enableAnimations: enabled);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAnimationSettings(updatedAnim);
  }

  Future<void> _updateAnimationSpeed(WidgetRef ref, String speed) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedAnim = current.animationSettings.copyWith(speed: speed);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAnimationSettings(updatedAnim);
  }

  Future<void> _updateAnimationOption(
      WidgetRef ref, String key, bool value) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedAnim = current.animationSettings.copyWith(
      enablePageTransitions: key == 'enablePageTransitions'
          ? value
          : current.animationSettings.enablePageTransitions,
      enableHoverEffects: key == 'enableHoverEffects'
          ? value
          : current.animationSettings.enableHoverEffects,
    );
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAnimationSettings(updatedAnim);
  }

  void _exportTheme(BuildContext context) {
    // Export theme logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _importTheme(BuildContext context) {
    // Import theme logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon!')),
    );
  }
}
