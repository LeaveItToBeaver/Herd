// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPostsFromController)
const userPostsFromControllerProvider = UserPostsFromControllerFamily._();

final class UserPostsFromControllerProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, Stream<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $StreamProvider<List<PostModel>> {
  const UserPostsFromControllerProvider._(
      {required UserPostsFromControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userPostsFromControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPostsFromControllerHash();

  @override
  String toString() {
    return r'userPostsFromControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PostModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userPostsFromController(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsFromControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsFromControllerHash() =>
    r'c515e71f6a23f19e51166bc41e7656c4fdd2ae3a';

final class UserPostsFromControllerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostModel>>, String> {
  const UserPostsFromControllerFamily._()
      : super(
          retry: null,
          name: r'userPostsFromControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserPostsFromControllerProvider call(
    String userId,
  ) =>
      UserPostsFromControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPostsFromControllerProvider';
}

@ProviderFor(userPublicPosts)
const userPublicPostsProvider = UserPublicPostsFamily._();

final class UserPublicPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  const UserPublicPostsProvider._(
      {required UserPublicPostsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userPublicPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPublicPostsHash();

  @override
  String toString() {
    return r'userPublicPostsProvider'
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
    return userPublicPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPublicPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPublicPostsHash() => r'cb065044f7cf07e0d9384eb6cc24c90d848913a3';

final class UserPublicPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const UserPublicPostsFamily._()
      : super(
          retry: null,
          name: r'userPublicPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserPublicPostsProvider call(
    String userId,
  ) =>
      UserPublicPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPublicPostsProvider';
}

@ProviderFor(userAltPosts)
const userAltPostsProvider = UserAltPostsFamily._();

final class UserAltPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  const UserAltPostsProvider._(
      {required UserAltPostsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userAltPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userAltPostsHash();

  @override
  String toString() {
    return r'userAltPostsProvider'
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
    return userAltPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserAltPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAltPostsHash() => r'1296672a011aab8595672d8b2d2471d62f601971';

final class UserAltPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const UserAltPostsFamily._()
      : super(
          retry: null,
          name: r'userAltPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserAltPostsProvider call(
    String userId,
  ) =>
      UserAltPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userAltPostsProvider';
}

@ProviderFor(postFromController)
const postFromControllerProvider = PostFromControllerFamily._();

final class PostFromControllerProvider extends $FunctionalProvider<
        AsyncValue<PostModel?>, PostModel?, Stream<PostModel?>>
    with $FutureModifier<PostModel?>, $StreamProvider<PostModel?> {
  const PostFromControllerProvider._(
      {required PostFromControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'postFromControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postFromControllerHash();

  @override
  String toString() {
    return r'postFromControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PostModel?> create(Ref ref) {
    final argument = this.argument as String;
    return postFromController(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostFromControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postFromControllerHash() =>
    r'04cc3e3946358dd50fa90fdb8ac35a4cd7fedefb';

final class PostFromControllerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostModel?>, String> {
  const PostFromControllerFamily._()
      : super(
          retry: null,
          name: r'postFromControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PostFromControllerProvider call(
    String postId,
  ) =>
      PostFromControllerProvider._(argument: postId, from: this);

  @override
  String toString() => r'postFromControllerProvider';
}

@ProviderFor(isPostLikedByUserFromController)
const isPostLikedByUserFromControllerProvider =
    IsPostLikedByUserFromControllerFamily._();

final class IsPostLikedByUserFromControllerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostLikedByUserFromControllerProvider._(
      {required IsPostLikedByUserFromControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isPostLikedByUserFromControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPostLikedByUserFromControllerHash();

  @override
  String toString() {
    return r'isPostLikedByUserFromControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isPostLikedByUserFromController(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostLikedByUserFromControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostLikedByUserFromControllerHash() =>
    r'ec9967fa07c5718a5a4ccaaa51fd15ba5e2981cd';

final class IsPostLikedByUserFromControllerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsPostLikedByUserFromControllerFamily._()
      : super(
          retry: null,
          name: r'isPostLikedByUserFromControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostLikedByUserFromControllerProvider call(
    String postId,
  ) =>
      IsPostLikedByUserFromControllerProvider._(argument: postId, from: this);

  @override
  String toString() => r'isPostLikedByUserFromControllerProvider';
}

@ProviderFor(isPostDislikedByUserFromController)
const isPostDislikedByUserFromControllerProvider =
    IsPostDislikedByUserFromControllerFamily._();

final class IsPostDislikedByUserFromControllerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostDislikedByUserFromControllerProvider._(
      {required IsPostDislikedByUserFromControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isPostDislikedByUserFromControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() =>
      _$isPostDislikedByUserFromControllerHash();

  @override
  String toString() {
    return r'isPostDislikedByUserFromControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isPostDislikedByUserFromController(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostDislikedByUserFromControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostDislikedByUserFromControllerHash() =>
    r'eb9424d73621d89df75f89e33091feed48b688ac';

final class IsPostDislikedByUserFromControllerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsPostDislikedByUserFromControllerFamily._()
      : super(
          retry: null,
          name: r'isPostDislikedByUserFromControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostDislikedByUserFromControllerProvider call(
    String postId,
  ) =>
      IsPostDislikedByUserFromControllerProvider._(
          argument: postId, from: this);

  @override
  String toString() => r'isPostDislikedByUserFromControllerProvider';
}

@ProviderFor(PostInteractions)
const postInteractionsProvider = PostInteractionsFamily._();

final class PostInteractionsProvider
    extends $NotifierProvider<PostInteractions, PostInteractionState> {
  const PostInteractionsProvider._(
      {required PostInteractionsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'postInteractionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postInteractionsHash();

  @override
  String toString() {
    return r'postInteractionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostInteractions create() => PostInteractions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostInteractionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postInteractionsHash() => r'02f3bca940151bef3c12a8827e5b5a2e8ba52b5b';

final class PostInteractionsFamily extends $Family
    with
        $ClassFamilyOverride<PostInteractions, PostInteractionState,
            PostInteractionState, PostInteractionState, String> {
  const PostInteractionsFamily._()
      : super(
          retry: null,
          name: r'postInteractionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PostInteractionsProvider call(
    String postId,
  ) =>
      PostInteractionsProvider._(argument: postId, from: this);

  @override
  String toString() => r'postInteractionsProvider';
}

abstract class _$PostInteractions extends $Notifier<PostInteractionState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  PostInteractionState build(
    String postId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<PostInteractionState, PostInteractionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PostInteractionState, PostInteractionState>,
        PostInteractionState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
