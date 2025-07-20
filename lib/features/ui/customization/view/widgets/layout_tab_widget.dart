import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';
import 'package:herdapp/features/ui/customization/view/widgets/optimistic_slider_widget.dart';

class LayoutTab extends ConsumerWidget {
  final UICustomizationModel customization;

  const LayoutTab({
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
          const SectionHeader(title: 'Content Density'),
          RadioListTile<String>(
            key: const Key('density_compact_radio'),
            title: const Text('Compact'),
            subtitle: const Text('Fit more content on screen'),
            value: 'compact',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(ref, value!),
          ),
          RadioListTile<String>(
            key: const Key('density_comfortable_radio'),
            title: const Text('Comfortable'),
            subtitle: const Text('Balanced spacing'),
            value: 'comfortable',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(ref, value!),
          ),
          RadioListTile<String>(
            key: const Key('density_spacious_radio'),
            title: const Text('Spacious'),
            subtitle: const Text('More breathing room'),
            value: 'spacious',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(ref, value!),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Feed Layout'),
          SwitchListTile(
            key: const Key('compact_posts_switch'),
            title: const Text('Use Compact Posts'),
            subtitle: const Text('Show more posts with less detail'),
            value: customization.layoutPreferences.useCompactPosts,
            onChanged: (value) =>
                _updateLayoutOption(ref, 'useCompactPosts', value),
          ),
          SwitchListTile(
            key: const Key('list_layout_switch'),
            title: const Text('Use List Layout'),
            subtitle: const Text('Show posts in a single column'),
            value: customization.layoutPreferences.useListLayout,
            onChanged: (value) =>
                _updateLayoutOption(ref, 'useListLayout', value),
          ),
          if (!customization.layoutPreferences.useListLayout)
            OptimisticSlider<int>(
              provider: gridColumnsSliderProvider,
              label: 'Grid Columns',
              min: 1,
              max: 4,
              divisions: 3,
              valueFormatter: (value) => value.toString(),
            ),
        ],
      ),
    );
  }

  Future<void> _updateDensity(WidgetRef ref, String density) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedPrefs = current.layoutPreferences.copyWith(density: density);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateLayoutPreferences(updatedPrefs);
  }

  Future<void> _updateLayoutOption(
      WidgetRef ref, String key, bool value) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedPrefs = current.layoutPreferences.copyWith(
      useCompactPosts: key == 'useCompactPosts'
          ? value
          : current.layoutPreferences.useCompactPosts,
      useListLayout: key == 'useListLayout'
          ? value
          : current.layoutPreferences.useListLayout,
    );
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateLayoutPreferences(updatedPrefs);
  }
}
