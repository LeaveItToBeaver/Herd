// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_type_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentFeed)
const currentFeedProvider = CurrentFeedProvider._();

final class CurrentFeedProvider
    extends $NotifierProvider<CurrentFeed, FeedType> {
  const CurrentFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentFeedHash();

  @$internal
  @override
  CurrentFeed create() => CurrentFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedType>(value),
    );
  }
}

String _$currentFeedHash() => r'20831ef146c882df44f50314a023ae89df60f817';

abstract class _$CurrentFeed extends $Notifier<FeedType> {
  FeedType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedType, FeedType>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FeedType, FeedType>, FeedType, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
