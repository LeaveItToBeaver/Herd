// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedRepository)
const feedRepositoryProvider = FeedRepositoryProvider._();

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  const FeedRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'fa6939b0e1f3149361594832a20e79ceecbf4fd0';

@ProviderFor(publicFeedCacheManager)
const publicFeedCacheManagerProvider = PublicFeedCacheManagerProvider._();

final class PublicFeedCacheManagerProvider
    extends $FunctionalProvider<CacheManager, CacheManager, CacheManager>
    with $Provider<CacheManager> {
  const PublicFeedCacheManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'publicFeedCacheManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$publicFeedCacheManagerHash();

  @$internal
  @override
  $ProviderElement<CacheManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheManager create(Ref ref) {
    return publicFeedCacheManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheManager>(value),
    );
  }
}

String _$publicFeedCacheManagerHash() =>
    r'45bbb1eef9c380b9b982c706ae50565aee260820';

/// Provider for the public feed controller

@ProviderFor(publicFeedController)
const publicFeedControllerProvider = PublicFeedControllerProvider._();

/// Provider for the public feed controller

final class PublicFeedControllerProvider extends $FunctionalProvider<
    PublicFeedController,
    PublicFeedController,
    PublicFeedController> with $Provider<PublicFeedController> {
  /// Provider for the public feed controller
  const PublicFeedControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'publicFeedControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$publicFeedControllerHash();

  @$internal
  @override
  $ProviderElement<PublicFeedController> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PublicFeedController create(Ref ref) {
    return publicFeedController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublicFeedController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublicFeedController>(value),
    );
  }
}

String _$publicFeedControllerHash() =>
    r'5e2004ff3160e53e9e3331c447bb54fd81c8353f';
