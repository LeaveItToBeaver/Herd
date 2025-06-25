import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:herdapp/features/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/customization/data/repositories/ui_customization_repository.dart';
import 'package:herdapp/features/customization/view/providers/ui_customization_provider.dart';
import 'package:herdapp/features/customization/view/providers/ui_customization_slider_providers.dart';
import 'package:herdapp/features/customization/view/widgets/optimistic_slider_widget.dart';

class UICustomizationScreen extends ConsumerStatefulWidget {
  const UICustomizationScreen({super.key});

  @override
  ConsumerState<UICustomizationScreen> createState() =>
      _UICustomizationScreenState();
}

class _UICustomizationScreenState extends ConsumerState<UICustomizationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Timer? _debounceTimer;
  double? _localFontScale;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounceTimer?.cancel();
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
            onPressed: () => _showResetDialog(),
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
      body: customizationAsync.when(
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
            ref.read(fontScaleSliderProvider.notifier).updatePersistedValue(
                  customization.typography.fontScaleFactor,
                );
            ref
                .read(shadowIntensitySliderProvider.notifier)
                .updatePersistedValue(customization.appTheme.shadowIntensity);
            ref.read(cardRadiusSliderProvider.notifier).updatePersistedValue(
                customization.componentStyles.cardBorderRadius);
            ref.read(gridColumnsSliderProvider.notifier).updatePersistedValue(
                customization.layoutPreferences.gridColumns);
            ref.read(buttonShapeSliderProvider.notifier).updatePersistedValue(
                customization.componentStyles.buttonBorderRadius);
          });

          return TabBarView(
            controller: _tabController,
            children: [
              _buildThemeTab(customization),
              _buildProfileTab(customization),
              _buildComponentsTab(customization),
              _buildLayoutTab(customization),
              _buildAdvancedTab(customization),
            ],
          );
        },
      ),
    );
  }

  // Theme customization tab
  Widget _buildThemeTab(UICustomizationModel customization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset themes
          _buildSectionHeader('Quick Themes'),
          _buildPresetThemes(),

          const SizedBox(height: 24),

          // Color customization
          _buildSectionHeader('Colors'),
          _buildColorPicker(
            'Primary Color',
            customization.appTheme.getPrimaryColor(),
            (color) => _updateColor('primary', color),
            key: 'primary_color_picker',
          ),
          _buildColorPicker(
            'Secondary Color',
            customization.appTheme.getSecondaryColor(),
            (color) => _updateColor('secondary', color),
            key: 'secondary_color_picker',
          ),
          _buildColorPicker(
            'Background Color',
            customization.appTheme.getBackgroundColor(),
            (color) => _updateColor('background', color),
            key: 'background_color_picker',
          ),
          _buildColorPicker(
            'Surface Color',
            customization.appTheme.getSurfaceColor(),
            (color) => _updateColor('surface', color),
            key: 'surface_color_picker',
          ),
          _buildColorPicker(
            'Text Color',
            customization.appTheme.getTextColor(),
            (color) => _updateColor('text', color),
            key: 'text_color_picker',
          ),

          const SizedBox(height: 24),

          // Effects
          _buildSectionHeader('Visual Effects'),
          SwitchListTile(
            key: const Key('glassmorphism_switch'),
            title: const Text('Enable Glassmorphism'),
            subtitle: const Text('Add frosted glass effects to components'),
            value: customization.appTheme.enableGlassmorphism,
            onChanged: (value) =>
                _updateThemeEffect('enableGlassmorphism', value),
          ),
          SwitchListTile(
            key: const Key('gradients_switch'),
            title: const Text('Enable Gradients'),
            subtitle: const Text('Use gradient colors throughout the app'),
            value: customization.appTheme.enableGradients,
            onChanged: (value) => _updateThemeEffect('enableGradients', value),
          ),
          SwitchListTile(
            key: const Key('shadows_switch'),
            title: const Text('Enable Shadows'),
            subtitle: const Text('Add depth with shadows'),
            value: customization.appTheme.enableShadows,
            onChanged: (value) => _updateThemeEffect('enableShadows', value),
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

  // Profile customization tab
  Widget _buildProfileTab(UICustomizationModel customization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Profile Background'),

          // Background type selector
          SegmentedButton<String>(
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
              _updateProfileBackground('backgroundType', selected.first);
            },
          ),

          const SizedBox(height: 16),

          // Layout options
          _buildSectionHeader('Profile Layout'),
          RadioListTile<String>(
            key: const Key('layout_classic_radio'),
            title: const Text('Classic'),
            subtitle: const Text('Traditional social media layout'),
            value: 'classic',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(value!),
          ),
          RadioListTile<String>(
            key: const Key('layout_modern_radio'),
            title: const Text('Modern'),
            subtitle: const Text('Clean, card-based design'),
            value: 'modern',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(value!),
          ),
          RadioListTile<String>(
            key: const Key('layout_creative_radio'),
            title: const Text('Creative'),
            subtitle: const Text('Express yourself with custom sections'),
            value: 'creative',
            groupValue: customization.profileCustomization.layout,
            onChanged: (value) => _updateProfileLayout(value!),
          ),

          const SizedBox(height: 24),

          // MySpace-style features
          _buildSectionHeader('Express Yourself'),
          SwitchListTile(
            key: const Key('music_player_switch'),
            title: const Text('Enable Music Player'),
            subtitle: const Text('Add background music to your profile'),
            value: customization.profileCustomization.enableMusicPlayer,
            onChanged: (value) =>
                _updateProfileFeature('enableMusicPlayer', value),
          ),
          SwitchListTile(
            key: const Key('particles_switch'),
            title: const Text('Enable Particles'),
            subtitle: const Text('Add floating particles effect'),
            value: customization.profileCustomization.enableParticles,
            onChanged: (value) =>
                _updateProfileFeature('enableParticles', value),
          ),
          SwitchListTile(
            key: const Key('animated_background_switch'),
            title: const Text('Enable Animated Background'),
            subtitle: const Text('Add motion to your profile background'),
            value: customization.profileCustomization.enableAnimatedBackground,
            onChanged: (value) =>
                _updateProfileFeature('enableAnimatedBackground', value),
          ),

          const SizedBox(height: 24),

          // Custom CSS input
          _buildSectionHeader('Custom CSS (Advanced)'),
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
            onChanged: (value) => _updateProfileCSS(value),
          ),
        ],
      ),
    );
  }

  // Components customization tab
  Widget _buildComponentsTab(UICustomizationModel customization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Button Styles'),

          // Button shape
          _buildDropdown<String>(
            'Button Shape',
            customization.componentStyles.primaryButton.shape,
            ['rounded', 'pill', 'square'],
            (value) => _updateButtonShape(value!),
            key: 'button_shape_dropdown',
          ),

          // Button radius
          OptimisticSlider<double>(
            provider: buttonShapeSliderProvider,
            label: 'Button Corner Radius',
            min: 0,
            max: 30,
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Card Styles'),
          OptimisticSlider<double>(
            provider: cardRadiusSliderProvider,
            label: 'Card Corner Radius',
            min: 0,
            max: 30,
          ),
          _buildSlider(
            'Card Elevation',
            customization.componentStyles.cardElevation,
            0,
            10,
            (value) => _updateCardElevation(value),
            key: 'card_elevation_slider',
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Navigation Style'),
          SwitchListTile(
            key: const Key('floating_nav_switch'),
            title: const Text('Floating Navigation'),
            subtitle: const Text('Make navigation bar float above content'),
            value: customization.componentStyles.navigation.floating,
            onChanged: (value) => _updateNavigationFloating(value),
          ),
          SwitchListTile(
            key: const Key('nav_labels_switch'),
            title: const Text('Show Labels'),
            subtitle: const Text('Display text labels in navigation'),
            value: customization.componentStyles.navigation.showLabels,
            onChanged: (value) => _updateNavigationLabels(value),
          ),
        ],
      ),
    );
  }

  // Layout customization tab
  Widget _buildLayoutTab(UICustomizationModel customization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Content Density'),
          RadioListTile<String>(
            key: const Key('density_compact_radio'),
            title: const Text('Compact'),
            subtitle: const Text('Fit more content on screen'),
            value: 'compact',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(value!),
          ),
          RadioListTile<String>(
            key: const Key('density_comfortable_radio'),
            title: const Text('Comfortable'),
            subtitle: const Text('Balanced spacing'),
            value: 'comfortable',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(value!),
          ),
          RadioListTile<String>(
            key: const Key('density_spacious_radio'),
            title: const Text('Spacious'),
            subtitle: const Text('More breathing room'),
            value: 'spacious',
            groupValue: customization.layoutPreferences.density,
            onChanged: (value) => _updateDensity(value!),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Feed Layout'),
          SwitchListTile(
            key: const Key('compact_posts_switch'),
            title: const Text('Use Compact Posts'),
            subtitle: const Text('Show more posts with less detail'),
            value: customization.layoutPreferences.useCompactPosts,
            onChanged: (value) => _updateLayoutOption('useCompactPosts', value),
          ),
          SwitchListTile(
            key: const Key('list_layout_switch'),
            title: const Text('Use List Layout'),
            subtitle: const Text('Show posts in a single column'),
            value: customization.layoutPreferences.useListLayout,
            onChanged: (value) => _updateLayoutOption('useListLayout', value),
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

  // Advanced customization tab
  Widget _buildAdvancedTab(UICustomizationModel customization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Typography'),
          _buildDropdown<String>(
            'Primary Font',
            customization.typography.primaryFont,
            [
              'Roboto',
              'Inter',
              'Open Sans',
              'Lato',
              'Montserrat',
              'Playfair Display'
            ],
            (value) => _updateFont(value!),
            key: 'font_dropdown',
          ),
          OptimisticSlider<double>(
            provider: fontScaleSliderProvider,
            label: 'Font Scale',
            min: 0.8,
            max: 1.5,
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Animations'),
          SwitchListTile(
            key: const Key('animations_enabled_switch'),
            title: const Text('Enable Animations'),
            subtitle: const Text('Turn off for better performance'),
            value: customization.animationSettings.enableAnimations,
            onChanged: (value) => _updateAnimationEnabled(value),
          ),
          if (customization.animationSettings.enableAnimations) ...[
            _buildDropdown<String>(
              'Animation Speed',
              customization.animationSettings.speed,
              ['slow', 'normal', 'fast', 'instant'],
              (value) => _updateAnimationSpeed(value!),
              key: 'animation_speed_dropdown',
            ),
            SwitchListTile(
              key: const Key('page_transitions_switch'),
              title: const Text('Page Transitions'),
              value: customization.animationSettings.enablePageTransitions,
              onChanged: (value) =>
                  _updateAnimationOption('enablePageTransitions', value),
            ),
            SwitchListTile(
              key: const Key('hover_effects_switch'),
              title: const Text('Hover Effects'),
              value: customization.animationSettings.enableHoverEffects,
              onChanged: (value) =>
                  _updateAnimationOption('enableHoverEffects', value),
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('Import/Export'),
          Row(
            children: [
              ElevatedButton.icon(
                key: const Key(
                    'export_theme_button'), // Use standard Key instead of GlobalKey
                icon: const Icon(Icons.file_download),
                label: const Text('Export Theme'),
                onPressed: _exportTheme,
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                key: const Key(
                    'import_theme_button'), // Use standard Key instead of GlobalKey
                icon: const Icon(Icons.file_upload),
                label: const Text('Import Theme'),
                onPressed: _importTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, Function(Color) onColorChanged,
      {required String key}) {
    return ListTile(
      key: Key(key),
      title: Text(label),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(label, currentColor, onColorChanged),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    int? divisions,
    required String key,
  }) {
    return Column(
      key: Key(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    Function(T?) onChanged, {
    required String key,
  }) {
    return Column(
      key: Key(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(_getDisplayName(item)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  String _getDisplayName(dynamic value) {
    if (value is String) {
      // Capitalize first letter
      if (value.isEmpty) return value;
      return value[0].toUpperCase() + value.substring(1);
    }
    return value.toString().split('.').last;
  }

  Widget _buildPresetThemes() {
    final repository = ref.read(uiCustomizationRepositoryProvider);
    final presets = repository.getAvailablePresets();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.entries.map((preset) {
        return ChoiceChip(
          key: Key('preset_${preset.key}'),
          label: Text(preset.value),
          selected: false,
          onSelected: (selected) {
            if (selected) {
              _applyPreset(preset.key);
            }
          },
        );
      }).toList(),
    );
  }

  void _showColorPicker(
      String label, Color currentColor, Function(Color) onColorChanged) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Pick $label'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setDialogState(() {
                    pickerColor = color;
                  });
                },
                enableAlpha: false,
                displayThumbColor: true,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onColorChanged(pickerColor);

                  // Commit the color change to Firebase.
                  ref
                      .read(uiCustomizationProvider.notifier)
                      .commitColorChanges();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateColor(String colorKey, Color color) {
    ref
        .read(uiCustomizationProvider.notifier)
        .updateColorInstant(colorKey, color);
  }

  Future<void> _updateThemeEffect(String key, dynamic value) async {
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

  Future<void> _updateProfileBackground(String key, dynamic value) async {
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

  Future<void> _updateProfileLayout(String layout) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile =
        current.profileCustomization.copyWith(layout: layout);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }

  Future<void> _updateProfileFeature(String key, bool value) async {
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

  Future<void> _updateProfileCSS(String css) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedProfile =
        current.profileCustomization.copyWith(customCSS: css);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateProfileCustomization(updatedProfile);
  }

  Future<void> _updateButtonShape(String shape) async {
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

  Future<void> _updateButtonRadius(double radius) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedButton =
        current.componentStyles.primaryButton.copyWith(borderRadius: radius);
    final updatedStyles =
        current.componentStyles.copyWith(primaryButton: updatedButton);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateCardRadius(double radius) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedStyles =
        current.componentStyles.copyWith(cardBorderRadius: radius);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateCardElevation(double elevation) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedStyles =
        current.componentStyles.copyWith(cardElevation: elevation);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateComponentStyles(updatedStyles);
  }

  Future<void> _updateNavigationFloating(bool floating) async {
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

  Future<void> _updateNavigationLabels(bool showLabels) async {
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

  Future<void> _updateDensity(String density) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedPrefs = current.layoutPreferences.copyWith(density: density);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateLayoutPreferences(updatedPrefs);
  }

  Future<void> _updateLayoutOption(String key, bool value) async {
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

  Future<void> _updateGridColumns(int columns) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedPrefs =
        current.layoutPreferences.copyWith(gridColumns: columns);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateLayoutPreferences(updatedPrefs);
  }

  Future<void> _updateFont(String font) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedTypo = current.typography.copyWith(primaryFont: font);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateTypography(updatedTypo);
  }

  Future<void> _updateFontScale(double scale) async {
// Update local state immediately for responsive UI
    setState(() {
      _localFontScale = scale;
    });

    // Cancel any existing timer
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Debounce only the persistence, not the UI update
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final current = ref.read(uiCustomizationProvider).value;
      if (current == null) return;

      try {
        final updatedTypo = current.typography.copyWith(fontScaleFactor: scale);
        await ref
            .read(uiCustomizationProvider.notifier)
            .updateTypography(updatedTypo);

        // Clear local state after successful persistence
        if (mounted) {
          setState(() {
            _localFontScale = null;
          });
        }
      } catch (e) {
        // Handle error - maybe revert local state or show error
        if (mounted) {
          setState(() {
            _localFontScale = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update font scale: $e')),
          );
        }
      }
    });
  }

  Future<void> _updateAnimationEnabled(bool enabled) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedAnim =
        current.animationSettings.copyWith(enableAnimations: enabled);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAnimationSettings(updatedAnim);
  }

  Future<void> _updateAnimationSpeed(String speed) async {
    final current = ref.read(uiCustomizationProvider).value;
    if (current == null) return;

    final updatedAnim = current.animationSettings.copyWith(speed: speed);
    await ref
        .read(uiCustomizationProvider.notifier)
        .updateAnimationSettings(updatedAnim);
  }

  Future<void> _updateAnimationOption(String key, bool value) async {
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

  void _applyPreset(String presetId) {
    ref.read(uiCustomizationProvider.notifier).applyPreset(presetId);
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'This will reset all customizations to the minimal theme. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Use the same preset mechanism that already works
              _applyPreset('minimal');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    // Navigate to a preview screen or show a dialog with preview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview functionality coming soon!')),
    );
  }

  void _exportTheme() async {
    // Export theme logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _importTheme() async {
    // Import theme logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon!')),
    );
  }
}
