// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsDragging)
const isDraggingProvider = IsDraggingProvider._();

final class IsDraggingProvider extends $NotifierProvider<IsDragging, bool> {
  const IsDraggingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isDraggingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isDraggingHash();

  @$internal
  @override
  IsDragging create() => IsDragging();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDraggingHash() => r'76febc4d3cb2665c4e4b22981de6749160171f62';

abstract class _$IsDragging extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
