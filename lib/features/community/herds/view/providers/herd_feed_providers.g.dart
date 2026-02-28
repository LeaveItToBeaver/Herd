// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'herd_feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cache manager provider for herd feed

@ProviderFor(herdFeedCacheManager)
const herdFeedCacheManagerProvider = HerdFeedCacheManagerProvider._();

/// Cache manager provider for herd feed

final class HerdFeedCacheManagerProvider
    extends $FunctionalProvider<CacheManager, CacheManager, CacheManager>
    with $Provider<CacheManager> {
  /// Cache manager provider for herd feed
  const HerdFeedCacheManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'herdFeedCacheManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdFeedCacheManagerHash();

  @$internal
  @override
  $ProviderElement<CacheManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheManager create(Ref ref) {
    return herdFeedCacheManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheManager>(value),
    );
  }
}

String _$herdFeedCacheManagerHash() =>
    r'1fb146699e35652bb88d2d9fa042068708c1c704';

/// Notifier for herd feed management

@ProviderFor(HerdFeed)
const herdFeedProvider = HerdFeedFamily._();

/// Notifier for herd feed management
final class HerdFeedProvider
    extends $NotifierProvider<HerdFeed, HerdFeedState> {
  /// Notifier for herd feed management
  const HerdFeedProvider._(
      {required HerdFeedFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'herdFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdFeedHash();

  @override
  String toString() {
    return r'herdFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HerdFeed create() => HerdFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HerdFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HerdFeedState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdFeedHash() => r'51998793362a9b83d117cd1c7f0a0a6993fbe70d';

/// Notifier for herd feed management

final class HerdFeedFamily extends $Family
    with
        $ClassFamilyOverride<HerdFeed, HerdFeedState, HerdFeedState,
            HerdFeedState, String> {
  const HerdFeedFamily._()
      : super(
          retry: null,
          name: r'herdFeedProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for herd feed management

  HerdFeedProvider call(
    String arg,
  ) =>
      HerdFeedProvider._(argument: arg, from: this);

  @override
  String toString() => r'herdFeedProvider';
}

/// Notifier for herd feed management

abstract class _$HerdFeed extends $Notifier<HerdFeedState> {
  late final _$args = ref.$arg as String;
  String get arg => _$args;

  HerdFeedState build(
    String arg,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<HerdFeedState, HerdFeedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HerdFeedState, HerdFeedState>,
        HerdFeedState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
