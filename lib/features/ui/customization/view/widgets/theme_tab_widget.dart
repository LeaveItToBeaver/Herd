import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';
import 'package:herdapp/features/ui/customization/view/widgets/optimistic_slider_widget.dart';

class ThemeTab extends ConsumerWidget {
  final UICustomizationModel customization;

  const ThemeTab({
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
          // Preset themes
          const SectionHeader(title: 'Quick Themes'),
          PresetThemes(
            onPresetSelected: (presetId) => _applyPreset(ref, presetId),
          ),

          const SizedBox(height: 24),

          // Color customization
          const SectionHeader(title: 'Colors'),
          CustomColorPicker(
            label: 'Primary Color',
            currentColor: customization.appTheme.getPrimaryColor(),
            onColorChanged: (color) => _updateColor(ref, 'primary', color),
            keyValue: 'primary_color_picker',
          ),
          CustomColorPicker(
            label: 'Secondary Color',
            currentColor: customization.appTheme.getSecondaryColor(),
            onColorChanged: (color) => _updateColor(ref, 'secondary', color),
            keyValue: 'secondary_color_picker',
          ),
          CustomColorPicker(
            label: 'Background Color',
            currentColor: customization.appTheme.getBackgroundColor(),
            onColorChanged: (color) => _updateColor(ref, 'background', color),
            keyValue: 'background_color_picker',
          ),
          CustomColorPicker(
            label: 'Surface Color',
            currentColor: customization.appTheme.getSurfaceColor(),
            onColorChanged: (color) => _updateColor(ref, 'surface', color),
            keyValue: 'surface_color_picker',
          ),
          CustomColorPicker(
            label: 'Text Color',
            currentColor: customization.appTheme.getTextColor(),
            onColorChanged: (color) => _updateColor(ref, 'text', color),
            keyValue: 'text_color_picker',
          ),

          const SizedBox(height: 24),

          // Effects
          const SectionHeader(title: 'Visual Effects'),
          SwitchListTile(
            key: const Key('glassmorphism_switch'),
            title: const Text('Enable Glassmorphism'),
            subtitle: const Text('Add frosted glass effects to components'),
            value: customization.appTheme.enableGlassmorphism,
            onChanged: (value) =>
                _updateThemeEffect(ref, 'enableGlassmorphism', value),
          ),
          SwitchListTile(
            key: const Key('gradients_switch'),
            title: const Text('Enable Gradients'),
            subtitle: const Text('Use gradient colors throughout the app'),
            value: customization.appTheme.enableGradients,
            onChanged: (value) =>
                _updateThemeEffect(ref, 'enableGradients', value),
          ),
          SwitchListTile(
            key: const Key('shadows_switch'),
            title: const Text('Enable Shadows'),
            subtitle: const Text('Add depth with shadows'),
            value: customization.appTheme.enableShadows,
            onChanged: (value) =>
                _updateThemeEffect(ref, 'enableShadows', value),
          ),
          if (customization.appTheme.enableShadows)
            OptimisticSlider<double>(
              provider: shadowIntensitySliderProvider,
              label: 'Shadow Intensity',
              min: 0.0,
              max: 3.0,
              divisions: 6,
            ),
        ],
      ),
    );
  }

  void _updateColor(WidgetRef ref, String colorKey, Color color) {
    ref
        .read(uiCustomizationProvider.notifier)
        .updateColorInstant(colorKey, color);

    // Commit the color change to Firebase
    ref.read(uiCustomizationProvider.notifier).commitColorChanges();
  }

  Future<void> _updateThemeEffect(
      WidgetRef ref, String key, dynamic value) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedTheme = current.appTheme.copyWith(
      enableGlassmorphism: key == 'enableGlassmorphism'
          ? value
          : current.appTheme.enableGlassmorphism,
      enableGradients:
          key == 'enableGradients' ? value : current.appTheme.enableGradients,
      enableShadows:
          key == 'enableShadows' ? value : current.appTheme.enableShadows,
      shadowIntensity:
          key == 'shadowIntensity' ? value : current.appTheme.shadowIntensity,
    );

    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAppTheme(updatedTheme);
  }

  void _applyPreset(WidgetRef ref, String presetId) {
    ref.read(uiCustomizationProvider.notifier).applyPreset(presetId);
  }
}
