// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_customization_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(uiCustomizationRepository)
const uiCustomizationRepositoryProvider = UiCustomizationRepositoryProvider._();

final class UiCustomizationRepositoryProvider extends $FunctionalProvider<
    UICustomizationRepository,
    UICustomizationRepository,
    UICustomizationRepository> with $Provider<UICustomizationRepository> {
  const UiCustomizationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'uiCustomizationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$uiCustomizationRepositoryHash();

  @$internal
  @override
  $ProviderElement<UICustomizationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UICustomizationRepository create(Ref ref) {
    return uiCustomizationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UICustomizationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UICustomizationRepository>(value),
    );
  }
}

String _$uiCustomizationRepositoryHash() =>
    r'7761cdae875da7621e5a7892e1e757047d94eace';
