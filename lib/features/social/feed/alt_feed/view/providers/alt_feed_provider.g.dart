// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(altFeedRepository)
const altFeedRepositoryProvider = AltFeedRepositoryProvider._();

final class AltFeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  const AltFeedRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'altFeedRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$altFeedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return altFeedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$altFeedRepositoryHash() => r'0d469a15346f7475e27e7ed58e63febd404aefc8';

@ProviderFor(altFeedCacheManager)
const altFeedCacheManagerProvider = AltFeedCacheManagerProvider._();

final class AltFeedCacheManagerProvider
    extends $FunctionalProvider<CacheManager, CacheManager, CacheManager>
    with $Provider<CacheManager> {
  const AltFeedCacheManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'altFeedCacheManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$altFeedCacheManagerHash();

  @$internal
  @override
  $ProviderElement<CacheManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheManager create(Ref ref) {
    return altFeedCacheManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheManager>(value),
    );
  }
}

String _$altFeedCacheManagerHash() =>
    r'50b22df529302f53b4e4302c3cf538ec8d1c0581';

/// Provider for the alt feed controller

@ProviderFor(altFeedController)
const altFeedControllerProvider = AltFeedControllerProvider._();

/// Provider for the alt feed controller

final class AltFeedControllerProvider extends $FunctionalProvider<
    AltFeedController,
    AltFeedController,
    AltFeedController> with $Provider<AltFeedController> {
  /// Provider for the alt feed controller
  const AltFeedControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'altFeedControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$altFeedControllerHash();

  @$internal
  @override
  $ProviderElement<AltFeedController> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AltFeedController create(Ref ref) {
    return altFeedController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AltFeedController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AltFeedController>(value),
    );
  }
}

String _$altFeedControllerHash() => r'7d249c9fa8710c3d14e02bfabbada021b67762a1';
