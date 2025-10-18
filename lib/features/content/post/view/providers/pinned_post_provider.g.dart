// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPinnedPosts)
const userPinnedPostsProvider = UserPinnedPostsFamily._();

final class UserPinnedPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  const UserPinnedPostsProvider._(
      {required UserPinnedPostsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userPinnedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPinnedPostsHash();

  @override
  String toString() {
    return r'userPinnedPostsProvider'
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
    return userPinnedPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPinnedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPinnedPostsHash() => r'1404f3f8183abd03efab8be0cf5349cbd0e31bce';

final class UserPinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const UserPinnedPostsFamily._()
      : super(
          retry: null,
          name: r'userPinnedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserPinnedPostsProvider call(
    String userId,
  ) =>
      UserPinnedPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPinnedPostsProvider';
}

@ProviderFor(userAltPinnedPosts)
const userAltPinnedPostsProvider = UserAltPinnedPostsFamily._();

final class UserAltPinnedPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  const UserAltPinnedPostsProvider._(
      {required UserAltPinnedPostsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userAltPinnedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userAltPinnedPostsHash();

  @override
  String toString() {
    return r'userAltPinnedPostsProvider'
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
    return userAltPinnedPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserAltPinnedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAltPinnedPostsHash() =>
    r'0ca13e8c5dd9caa1ea47b91891c242ffb4f3479c';

final class UserAltPinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const UserAltPinnedPostsFamily._()
      : super(
          retry: null,
          name: r'userAltPinnedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserAltPinnedPostsProvider call(
    String userId,
  ) =>
      UserAltPinnedPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userAltPinnedPostsProvider';
}

@ProviderFor(herdPinnedPosts)
const herdPinnedPostsProvider = HerdPinnedPostsFamily._();

final class HerdPinnedPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  const HerdPinnedPostsProvider._(
      {required HerdPinnedPostsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdPinnedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdPinnedPostsHash();

  @override
  String toString() {
    return r'herdPinnedPostsProvider'
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
    return herdPinnedPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdPinnedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdPinnedPostsHash() => r'79095d0d5782a2a8e290c1d76687135d89a9da79';

final class HerdPinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const HerdPinnedPostsFamily._()
      : super(
          retry: null,
          name: r'herdPinnedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  HerdPinnedPostsProvider call(
    String herdId,
  ) =>
      HerdPinnedPostsProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdPinnedPostsProvider';
}

@ProviderFor(isPostPinnedToProfile)
const isPostPinnedToProfileProvider = IsPostPinnedToProfileFamily._();

final class IsPostPinnedToProfileProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostPinnedToProfileProvider._(
      {required IsPostPinnedToProfileFamily super.from,
      required (
        String,
        String,
        bool,
      )
          super.argument})
      : super(
          retry: null,
          name: r'isPostPinnedToProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPostPinnedToProfileHash();

  @override
  String toString() {
    return r'isPostPinnedToProfileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
      bool,
    );
    return isPostPinnedToProfile(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostPinnedToProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostPinnedToProfileHash() =>
    r'd26b5c494b1e0b5e554f9287c8f8af547047d50c';

final class IsPostPinnedToProfileFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<bool>,
            (
              String,
              String,
              bool,
            )> {
  const IsPostPinnedToProfileFamily._()
      : super(
          retry: null,
          name: r'isPostPinnedToProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostPinnedToProfileProvider call(
    String userId,
    String postId,
    bool isAlt,
  ) =>
      IsPostPinnedToProfileProvider._(argument: (
        userId,
        postId,
        isAlt,
      ), from: this);

  @override
  String toString() => r'isPostPinnedToProfileProvider';
}

@ProviderFor(isPostPinnedToHerd)
const isPostPinnedToHerdProvider = IsPostPinnedToHerdFamily._();

final class IsPostPinnedToHerdProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostPinnedToHerdProvider._(
      {required IsPostPinnedToHerdFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'isPostPinnedToHerdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPostPinnedToHerdHash();

  @override
  String toString() {
    return r'isPostPinnedToHerdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return isPostPinnedToHerd(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostPinnedToHerdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostPinnedToHerdHash() =>
    r'30f68ed61534c198ab216311cd93da039b3731f9';

final class IsPostPinnedToHerdFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<bool>,
            (
              String,
              String,
            )> {
  const IsPostPinnedToHerdFamily._()
      : super(
          retry: null,
          name: r'isPostPinnedToHerdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostPinnedToHerdProvider call(
    String herdId,
    String postId,
  ) =>
      IsPostPinnedToHerdProvider._(argument: (
        herdId,
        postId,
      ), from: this);

  @override
  String toString() => r'isPostPinnedToHerdProvider';
}

@ProviderFor(pinnedPostsController)
const pinnedPostsControllerProvider = PinnedPostsControllerProvider._();

final class PinnedPostsControllerProvider extends $FunctionalProvider<
    PinnedPostsController,
    PinnedPostsController,
    PinnedPostsController> with $Provider<PinnedPostsController> {
  const PinnedPostsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pinnedPostsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pinnedPostsControllerHash();

  @$internal
  @override
  $ProviderElement<PinnedPostsController> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinnedPostsController create(Ref ref) {
    return pinnedPostsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinnedPostsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinnedPostsController>(value),
    );
  }
}

String _$pinnedPostsControllerHash() =>
    r'c72096d6f067dbcdcbc5094b2f57c8a960e91ff4';
