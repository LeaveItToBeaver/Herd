// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postRepository)
const postRepositoryProvider = PostRepositoryProvider._();

final class PostRepositoryProvider
    extends $FunctionalProvider<PostRepository, PostRepository, PostRepository>
    with $Provider<PostRepository> {
  const PostRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postRepositoryHash();

  @$internal
  @override
  $ProviderElement<PostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostRepository create(Ref ref) {
    return postRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostRepository>(value),
    );
  }
}

String _$postRepositoryHash() => r'68e7e90385b54239744ca6858f1e86f11993f1f3';

@ProviderFor(userPosts)
const userPostsProvider = UserPostsFamily._();

final class UserPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, Stream<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $StreamProvider<List<PostModel>> {
  const UserPostsProvider._(
      {required UserPostsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPostsHash();

  @override
  String toString() {
    return r'userPostsProvider'
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
    return userPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userPostsHash() => r'13c125bbc2f4a01fe0da1337f5a35203f2250d18';

final class UserPostsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostModel>>, String> {
  const UserPostsFamily._()
      : super(
          retry: null,
          name: r'userPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserPostsProvider call(
    String userId,
  ) =>
      UserPostsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userPostsProvider';
}

@ProviderFor(post)
const postProvider = PostFamily._();

final class PostProvider extends $FunctionalProvider<AsyncValue<PostModel?>,
        PostModel?, Stream<PostModel?>>
    with $FutureModifier<PostModel?>, $StreamProvider<PostModel?> {
  const PostProvider._(
      {required PostFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'postProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postHash();

  @override
  String toString() {
    return r'postProvider'
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
    return post(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postHash() => r'b3c7219718f26d5109cff62f17fa55f217d5cab0';

final class PostFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostModel?>, String> {
  const PostFamily._()
      : super(
          retry: null,
          name: r'postProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PostProvider call(
    String postId,
  ) =>
      PostProvider._(argument: postId, from: this);

  @override
  String toString() => r'postProvider';
}

@ProviderFor(postWithPrivacy)
const postWithPrivacyProvider = PostWithPrivacyFamily._();

final class PostWithPrivacyProvider extends $FunctionalProvider<
        AsyncValue<PostModel?>, PostModel?, Stream<PostModel?>>
    with $FutureModifier<PostModel?>, $StreamProvider<PostModel?> {
  const PostWithPrivacyProvider._(
      {required PostWithPrivacyFamily super.from,
      required PostParams super.argument})
      : super(
          retry: null,
          name: r'postWithPrivacyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postWithPrivacyHash();

  @override
  String toString() {
    return r'postWithPrivacyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PostModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PostModel?> create(Ref ref) {
    final argument = this.argument as PostParams;
    return postWithPrivacy(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostWithPrivacyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postWithPrivacyHash() => r'3b8a263171bb601cb60506c68910ac04f1ce4bb2';

final class PostWithPrivacyFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PostModel?>, PostParams> {
  const PostWithPrivacyFamily._()
      : super(
          retry: null,
          name: r'postWithPrivacyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PostWithPrivacyProvider call(
    PostParams params,
  ) =>
      PostWithPrivacyProvider._(argument: params, from: this);

  @override
  String toString() => r'postWithPrivacyProvider';
}

@ProviderFor(staticPost)
const staticPostProvider = StaticPostFamily._();

final class StaticPostProvider extends $FunctionalProvider<
        AsyncValue<PostModel?>, PostModel?, FutureOr<PostModel?>>
    with $FutureModifier<PostModel?>, $FutureProvider<PostModel?> {
  const StaticPostProvider._(
      {required StaticPostFamily super.from,
      required PostParams super.argument})
      : super(
          retry: null,
          name: r'staticPostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$staticPostHash();

  @override
  String toString() {
    return r'staticPostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PostModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PostModel?> create(Ref ref) {
    final argument = this.argument as PostParams;
    return staticPost(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StaticPostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staticPostHash() => r'65d97e2d4a90b9ca0dd99666aa3750d07dff9ca9';

final class StaticPostFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PostModel?>, PostParams> {
  const StaticPostFamily._()
      : super(
          retry: null,
          name: r'staticPostProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  StaticPostProvider call(
    PostParams params,
  ) =>
      StaticPostProvider._(argument: params, from: this);

  @override
  String toString() => r'staticPostProvider';
}

@ProviderFor(isPostLikedByUser)
const isPostLikedByUserProvider = IsPostLikedByUserFamily._();

final class IsPostLikedByUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostLikedByUserProvider._(
      {required IsPostLikedByUserFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isPostLikedByUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPostLikedByUserHash();

  @override
  String toString() {
    return r'isPostLikedByUserProvider'
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
    return isPostLikedByUser(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostLikedByUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostLikedByUserHash() => r'01a331f8733b043df6ac92f26225f35d0eb3c43d';

final class IsPostLikedByUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsPostLikedByUserFamily._()
      : super(
          retry: null,
          name: r'isPostLikedByUserProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostLikedByUserProvider call(
    String postId,
  ) =>
      IsPostLikedByUserProvider._(argument: postId, from: this);

  @override
  String toString() => r'isPostLikedByUserProvider';
}

@ProviderFor(isPostDislikedByUser)
const isPostDislikedByUserProvider = IsPostDislikedByUserFamily._();

final class IsPostDislikedByUserProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsPostDislikedByUserProvider._(
      {required IsPostDislikedByUserFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isPostDislikedByUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPostDislikedByUserHash();

  @override
  String toString() {
    return r'isPostDislikedByUserProvider'
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
    return isPostDislikedByUser(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostDislikedByUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isPostDislikedByUserHash() =>
    r'b61fa7c7c5e782a8daa970ec8bf74565b800af54';

final class IsPostDislikedByUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsPostDislikedByUserFamily._()
      : super(
          retry: null,
          name: r'isPostDislikedByUserProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsPostDislikedByUserProvider call(
    String postId,
  ) =>
      IsPostDislikedByUserProvider._(argument: postId, from: this);

  @override
  String toString() => r'isPostDislikedByUserProvider';
}

@ProviderFor(PostInteractionsWithPrivacy)
const postInteractionsWithPrivacyProvider =
    PostInteractionsWithPrivacyFamily._();

final class PostInteractionsWithPrivacyProvider extends $NotifierProvider<
    PostInteractionsWithPrivacy, PostInteractionState> {
  const PostInteractionsWithPrivacyProvider._(
      {required PostInteractionsWithPrivacyFamily super.from,
      required PostParams super.argument})
      : super(
          retry: null,
          name: r'postInteractionsWithPrivacyProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postInteractionsWithPrivacyHash();

  @override
  String toString() {
    return r'postInteractionsWithPrivacyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostInteractionsWithPrivacy create() => PostInteractionsWithPrivacy();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostInteractionsWithPrivacyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postInteractionsWithPrivacyHash() =>
    r'9569a33bdfb1eed6693f059a800ae6e935030dcd';

final class PostInteractionsWithPrivacyFamily extends $Family
    with
        $ClassFamilyOverride<PostInteractionsWithPrivacy, PostInteractionState,
            PostInteractionState, PostInteractionState, PostParams> {
  const PostInteractionsWithPrivacyFamily._()
      : super(
          retry: null,
          name: r'postInteractionsWithPrivacyProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  PostInteractionsWithPrivacyProvider call(
    PostParams params,
  ) =>
      PostInteractionsWithPrivacyProvider._(argument: params, from: this);

  @override
  String toString() => r'postInteractionsWithPrivacyProvider';
}

abstract class _$PostInteractionsWithPrivacy
    extends $Notifier<PostInteractionState> {
  late final _$args = ref.$arg as PostParams;
  PostParams get params => _$args;

  PostInteractionState build(
    PostParams params,
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
