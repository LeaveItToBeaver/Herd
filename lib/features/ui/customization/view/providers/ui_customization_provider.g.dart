// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_customization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(uiCustomizationStream)
const uiCustomizationStreamProvider = UiCustomizationStreamProvider._();

final class UiCustomizationStreamProvider extends $FunctionalProvider<
        AsyncValue<UICustomizationModel?>,
        UICustomizationModel?,
        Stream<UICustomizationModel?>>
    with
        $FutureModifier<UICustomizationModel?>,
        $StreamProvider<UICustomizationModel?> {
  const UiCustomizationStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uiCustomizationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uiCustomizationStreamHash();

  @$internal
  @override
  $StreamProviderElement<UICustomizationModel?> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UICustomizationModel?> create(Ref ref) {
    return uiCustomizationStream(ref);
  }
}

String _$uiCustomizationStreamHash() =>
    r'd7934b5f75d9fb6cb21f07a9824d600d05878510';

@ProviderFor(UICustomization)
const uICustomizationProvider = UICustomizationProvider._();

final class UICustomizationProvider
    extends $AsyncNotifierProvider<UICustomization, UICustomizationModel?> {
  const UICustomizationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uICustomizationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uICustomizationHash();

  @$internal
  @override
  UICustomization create() => UICustomization();
}

String _$uICustomizationHash() => r'36c674a2d59c046842fa16c5133ddc5941657880';

abstract class _$UICustomization extends $AsyncNotifier<UICustomizationModel?> {
  FutureOr<UICustomizationModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<UICustomizationModel?>, UICustomizationModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UICustomizationModel?>, UICustomizationModel?>,
        AsyncValue<UICustomizationModel?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(currentTheme)
const currentThemeProvider = CurrentThemeProvider._();

final class CurrentThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  const CurrentThemeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentThemeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return currentTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$currentThemeHash() => r'cfe37c9397678fb0594b42ae9385ff9103367119';
