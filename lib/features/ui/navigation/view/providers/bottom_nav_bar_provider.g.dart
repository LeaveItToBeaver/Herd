// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottom_nav_bar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BottomNav)
const bottomNavProvider = BottomNavProvider._();

final class BottomNavProvider
    extends $NotifierProvider<BottomNav, BottomNavItem> {
  const BottomNavProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bottomNavProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bottomNavHash();

  @$internal
  @override
  BottomNav create() => BottomNav();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BottomNavItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BottomNavItem>(value),
    );
  }
}

String _$bottomNavHash() => r'ccb01d92db0f0aa1fcc4c11dff9d4f91886379c2';

abstract class _$BottomNav extends $Notifier<BottomNavItem> {
  BottomNavItem build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BottomNavItem, BottomNavItem>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BottomNavItem, BottomNavItem>,
        BottomNavItem,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
