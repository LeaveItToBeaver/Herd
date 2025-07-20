import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/ui/customization/view/widgets/customization_helper_widgets.dart';

class ProfileTab extends ConsumerWidget {
  final UICustomizationModel customization;

  const ProfileTab({
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
          const SectionHeader(title: 'Profile Background'),

          // Background type selector
          SegmentedButton<String>(
            style: SegmentedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            key: const Key('background_type_selector'),
            segments: const [
              ButtonSegment(
                value: 'solid',
                label: Text('Solid'),
                icon: Icon(Icons.square),
              ),
              ButtonSegment(
                value: 'gradient',
                label: Text('Gradient'),
                icon: Icon(Icons.gradient),
              ),
              ButtonSegment(
                value: 'image',
                label: Text('Image'),
                icon: Icon(Icons.image),
              ),
              ButtonSegment(
                value: 'animated',
                label: Text('Animated'),
                icon: Icon(Icons.animation),
              ),
            ],
            selected: {customization.profileCustomization.backgroundType},
            onSelectionChanged: (Set<String> selected) {
              _updateProfileBackground(ref, 'backgroundType', selected.first);
            },
          ),

          const SizedBox(height: 16),

          // Layout options
          const SectionHeader(title: 'Profile Layout'),
          RadioListTile<String>(
            key: const Key('layout_classic_radio'),
            title: const Text('Classic'),
            subtitle: const Text('Traditional social media layout'),
            value: 'classic',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(ref, value!),
          ),
          RadioListTile<String>(
            key: const Key('layout_modern_radio'),
            title: const Text('Modern'),
            subtitle: const Text('Clean, card-based design'),
            value: 'modern',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(ref, value!),
          ),
          RadioListTile<String>(
            key: const Key('layout_creative_radio'),
            title: const Text('Creative'),
            subtitle: const Text('Express yourself with custom sections'),
            value: 'creative',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(ref, value!),
          ),

          const SizedBox(height: 24),

          // MySpace-style features
          const SectionHeader(title: 'Express Yourself'),
          SwitchListTile(
            key: const Key('music_player_switch'),
            title: const Text('Enable Music Player'),
            subtitle: const Text('Add background music to your profile'),
            value: customization.profileCustomization.enableMusicPlayer,
            onChanged: (value) =>
                _updateProfileFeature(ref, 'enableMusicPlayer', value),
          ),
          SwitchListTile(
            key: const Key('particles_switch'),
            title: const Text('Enable Particles'),
            subtitle: const Text('Add floating particles effect'),
            value: customization.profileCustomization.enableParticles,
            onChanged: (value) =>
                _updateProfileFeature(ref, 'enableParticles', value),
          ),
          SwitchListTile(
            key: const Key('animated_background_switch'),
            title: const Text('Enable Animated Background'),
            subtitle: const Text('Add motion to your profile background'),
            value: customization.profileCustomization.enableAnimatedBackground,
            onChanged: (value) =>
                _updateProfileFeature(ref, 'enableAnimatedBackground', value),
          ),

          const SizedBox(height: 24),

          // Custom CSS input
          const SectionHeader(title: 'Custom CSS (Advanced)'),
          TextField(
            key: const Key('custom_css_field'),
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  'Enter custom CSS to style your profile. This is an advanced feature and may break your profile if used incorrectly.',
              helperText:
                  'Use standard CSS syntax. Changes apply to your profile only.',
            ),
            style: const TextStyle(fontFamily: 'monospace'),
            onChanged: (value) => _updateProfileCSS(ref, value),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfileBackground(
      WidgetRef ref, String key, dynamic value) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile = current.profileCustomization.copyWith(
      backgroundType: key == 'backgroundType'
          ? value
          : current.profileCustomization.backgroundType,
    );

    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }

  Future<void> _updateProfileLayout(WidgetRef ref, String layout) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile =
        current.profileCustomization.copyWith(layout: layout);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }

  Future<void> _updateProfileFeature(
      WidgetRef ref, String key, bool value) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile = current.profileCustomization.copyWith(
      enableMusicPlayer: key == 'enableMusicPlayer'
          ? value
          : current.profileCustomization.enableMusicPlayer,
      enableParticles: key == 'enableParticles'
          ? value
          : current.profileCustomization.enableParticles,
      enableAnimatedBackground: key == 'enableAnimatedBackground'
          ? value
          : current.profileCustomization.enableAnimatedBackground,
    );

    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }

  Future<void> _updateProfileCSS(WidgetRef ref, String css) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile =
        current.profileCustomization.copyWith(customCSS: css);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }
}
