import 'package:herdapp/features/ui/customization/view/providers/optimistic_slider_provider.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';

// Font scale slider provider
// final fontScaleSliderProvider = createOptimisticSliderProvider<double>(
//   name: 'fontScaleSlider',
//   persistFunction: (value, ref) async {
//     // Get the container to access other providers
//     final container = ProviderContainer();

//     try {
//       final current = container.read(uiCustomizationProvider).value;
//       if (current == null) return;

//       final updatedTypo = current.typography.copyWith(fontScaleFactor: value);
//       await container
//           .read(uiCustomizationProvider.notifier)
//           .updateTypography(updatedTypo);
//     } finally {
//       container.dispose();
//     }
//   },
//   initialValue: 1.0,
// );

final fontScaleSliderProvider = createOptimisticSliderProvider<double>(
  name: 'fontScaleSlider',
  persistFunction: (value, ref) async {
    final uiNotifier = ref.read(uiCustomizationProvider.notifier);
    final currentCustomization = ref.read(uiCustomizationProvider).value;

    if (currentCustomization == null) return;
    final updatedTypo = currentCustomization.typography.copyWith(
      fontScaleFactor: value,
    );
    await uiNotifier.updateTypography(updatedTypo);
  },
  initialValue: 1.0,
);

// Shadow intensity slider provider
final shadowIntensitySliderProvider = createOptimisticSliderProvider<double>(
  name: 'shadowIntensitySlider',
  persistFunction: (value, ref) async {
    final uiNotifier = ref.read(uiCustomizationProvider.notifier);
    final currentCustomization = ref.read(uiCustomizationProvider).value;

    if (currentCustomization == null) return;
    final updatedStyles = currentCustomization.appTheme.copyWith(
      shadowIntensity: value,
    );
    await uiNotifier.updateAppTheme(updatedStyles);
  },
  initialValue: 1.0,
);

// Card radius slider provider
final cardRadiusSliderProvider = createOptimisticSliderProvider<double>(
  name: 'cardRadiusSlider',
  persistFunction: (value, ref) async {
    final uiNotifier = ref.read(uiCustomizationProvider.notifier);
    final currentCustomization = ref.read(uiCustomizationProvider).value;

    if (currentCustomization == null) return;
    final updatedStyles = currentCustomization.componentStyles.copyWith(
      cardBorderRadius: value,
    );
    await uiNotifier.updateComponentStyles(updatedStyles);
  },
  initialValue: 8.0,
);

// Grid columns slider provider
final gridColumnsSliderProvider = createOptimisticSliderProvider<int>(
  name: 'gridColumnsSlider',
  persistFunction: (value, ref) async {
    final uiNotifier = ref.read(uiCustomizationProvider.notifier);
    final currentCustomization = ref.read(uiCustomizationProvider).value;

    if (currentCustomization == null) return;
    final updatedPrefs = currentCustomization.layoutPreferences.copyWith(
      gridColumns: value,
    );
    await uiNotifier.updateLayoutPreferences(updatedPrefs);
  },
  initialValue: 2,
);

// Button Shaope slider provider
final buttonShapeSliderProvider = createOptimisticSliderProvider<double>(
  name: 'buttonShapeSlider',
  persistFunction: (value, ref) async {
    final uiNotifier = ref.read(uiCustomizationProvider.notifier);
    final currentCustomization = ref.read(uiCustomizationProvider).value;

    if (currentCustomization == null) return;
    final updatedStyles = currentCustomization.componentStyles.copyWith(
      buttonBorderRadius: value,
    );
    await uiNotifier.updateComponentStyles(updatedStyles);
  },
  initialValue: 4.0,
);
