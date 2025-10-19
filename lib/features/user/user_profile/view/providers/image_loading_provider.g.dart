// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_loading_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageLoading)
const imageLoadingProvider = ImageLoadingProvider._();

final class ImageLoadingProvider extends $NotifierProvider<ImageLoading, bool> {
  const ImageLoadingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'imageLoadingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$imageLoadingHash();

  @$internal
  @override
  ImageLoading create() => ImageLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$imageLoadingHash() => r'2f5488e7654f20aa6d45651145e21f41faf7b72e';

abstract class _$ImageLoading extends $Notifier<bool> {
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
