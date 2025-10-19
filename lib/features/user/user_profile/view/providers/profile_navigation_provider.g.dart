// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileNavigation)
const profileNavigationProvider = ProfileNavigationProvider._();

final class ProfileNavigationProvider extends $FunctionalProvider<
    ProfileNavigation,
    ProfileNavigation,
    ProfileNavigation> with $Provider<ProfileNavigation> {
  const ProfileNavigationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileNavigationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileNavigationHash();

  @$internal
  @override
  $ProviderElement<ProfileNavigation> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileNavigation create(Ref ref) {
    return profileNavigation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileNavigation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileNavigation>(value),
    );
  }
}

String _$profileNavigationHash() => r'25d0862b283be16d7707fbbba97bd78b1a15f912';
