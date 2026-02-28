// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(navigationService)
const navigationServiceProvider = NavigationServiceProvider._();

final class NavigationServiceProvider extends $FunctionalProvider<
    NavigationService,
    NavigationService,
    NavigationService> with $Provider<NavigationService> {
  const NavigationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'navigationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$navigationServiceHash();

  @$internal
  @override
  $ProviderElement<NavigationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NavigationService create(Ref ref) {
    return navigationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationService>(value),
    );
  }
}

String _$navigationServiceHash() => r'7aa3a928ff02a6149ab847e3fe985a33abd8b01d';
