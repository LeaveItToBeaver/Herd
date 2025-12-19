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
          isAutoDispose: false,
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

String _$altFeedRepositoryHash() => r'5641df64e258451286a45728b3ca85ca825959e0';

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
          isAutoDispose: false,
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
    r'34eefc7597b83d7f16f7dba7efea42c4078edfa1';

/// Riverpod-native alt feed state + actions.

@ProviderFor(AltFeedStateNotifier)
const altFeedStateProvider = AltFeedStateNotifierProvider._();

/// Riverpod-native alt feed state + actions.
final class AltFeedStateNotifierProvider
    extends $NotifierProvider<AltFeedStateNotifier, AltFeedState> {
  /// Riverpod-native alt feed state + actions.
  const AltFeedStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'altFeedStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$altFeedStateNotifierHash();

  @$internal
  @override
  AltFeedStateNotifier create() => AltFeedStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AltFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AltFeedState>(value),
    );
  }
}

String _$altFeedStateNotifierHash() =>
    r'acd4cb00ed304fb1f7597eaffdb9be7cdbf5a3c6';

/// Riverpod-native alt feed state + actions.

abstract class _$AltFeedStateNotifier extends $Notifier<AltFeedState> {
  AltFeedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AltFeedState, AltFeedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AltFeedState, AltFeedState>,
        AltFeedState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
