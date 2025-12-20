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
          isAutoDispose: false,
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

String _$feedRepositoryHash() => r'70051a5f7b27ab14a4d7832ee1b179696d7a2a18';

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
          isAutoDispose: false,
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
    r'67b2caffb376bdc92f878581e99b0d0ff16b968d';

/// Riverpod-native public feed state + actions.
/// Uses keepAlive: true to persist state across navigation.

@ProviderFor(PublicFeedStateNotifier)
const publicFeedStateProvider = PublicFeedStateNotifierProvider._();

/// Riverpod-native public feed state + actions.
/// Uses keepAlive: true to persist state across navigation.
final class PublicFeedStateNotifierProvider
    extends $NotifierProvider<PublicFeedStateNotifier, PublicFeedState> {
  /// Riverpod-native public feed state + actions.
  /// Uses keepAlive: true to persist state across navigation.
  const PublicFeedStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'publicFeedStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$publicFeedStateNotifierHash();

  @$internal
  @override
  PublicFeedStateNotifier create() => PublicFeedStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublicFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublicFeedState>(value),
    );
  }
}

String _$publicFeedStateNotifierHash() =>
    r'b7ff018eb6453df07c4ecc4074acacb317b14a1a';

/// Riverpod-native public feed state + actions.
/// Uses keepAlive: true to persist state across navigation.

abstract class _$PublicFeedStateNotifier extends $Notifier<PublicFeedState> {
  PublicFeedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PublicFeedState, PublicFeedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PublicFeedState, PublicFeedState>,
        PublicFeedState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
