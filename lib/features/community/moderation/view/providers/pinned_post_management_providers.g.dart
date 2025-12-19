// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_post_management_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads a herd's pinned posts using parallel reads across the 3 possible
/// post locations (herdPosts, posts, altPosts).

@ProviderFor(herdPinnedPostsBatch)
const herdPinnedPostsBatchProvider = HerdPinnedPostsBatchFamily._();

/// Loads a herd's pinned posts using parallel reads across the 3 possible
/// post locations (herdPosts, posts, altPosts).

final class HerdPinnedPostsBatchProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  /// Loads a herd's pinned posts using parallel reads across the 3 possible
  /// post locations (herdPosts, posts, altPosts).
  const HerdPinnedPostsBatchProvider._(
      {required HerdPinnedPostsBatchFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdPinnedPostsBatchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdPinnedPostsBatchHash();

  @override
  String toString() {
    return r'herdPinnedPostsBatchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostModel>> create(Ref ref) {
    final argument = this.argument as String;
    return herdPinnedPostsBatch(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdPinnedPostsBatchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdPinnedPostsBatchHash() =>
    r'3198e2f8cfa4d4495cd1dbe7e09d2973eb2ec42a';

/// Loads a herd's pinned posts using parallel reads across the 3 possible
/// post locations (herdPosts, posts, altPosts).

final class HerdPinnedPostsBatchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const HerdPinnedPostsBatchFamily._()
      : super(
          retry: null,
          name: r'herdPinnedPostsBatchProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Loads a herd's pinned posts using parallel reads across the 3 possible
  /// post locations (herdPosts, posts, altPosts).

  HerdPinnedPostsBatchProvider call(
    String herdId,
  ) =>
      HerdPinnedPostsBatchProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdPinnedPostsBatchProvider';
}

@ProviderFor(pinnedPostModerationRepository)
const pinnedPostModerationRepositoryProvider =
    PinnedPostModerationRepositoryProvider._();

final class PinnedPostModerationRepositoryProvider extends $FunctionalProvider<
    ModerationRepository,
    ModerationRepository,
    ModerationRepository> with $Provider<ModerationRepository> {
  const PinnedPostModerationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pinnedPostModerationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pinnedPostModerationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ModerationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModerationRepository create(Ref ref) {
    return pinnedPostModerationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerationRepository>(value),
    );
  }
}

String _$pinnedPostModerationRepositoryHash() =>
    r'da6e261f92ad0a244266180cd08939dbd41341f2';
