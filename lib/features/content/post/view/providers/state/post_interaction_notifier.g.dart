// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_interaction_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostInteractionsNotifier)
const postInteractionsProvider = PostInteractionsNotifierFamily._();

final class PostInteractionsNotifierProvider
    extends $NotifierProvider<PostInteractionsNotifier, PostInteractionState> {
  const PostInteractionsNotifierProvider._(
      {required PostInteractionsNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'postInteractionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postInteractionsNotifierHash();

  @override
  String toString() {
    return r'postInteractionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostInteractionsNotifier create() => PostInteractionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PostInteractionsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postInteractionsNotifierHash() =>
    r'd95016c75f310a42f6e8dafe9b3e2011f95ab068';

final class PostInteractionsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<PostInteractionsNotifier, PostInteractionState,
            PostInteractionState, PostInteractionState, String> {
  const PostInteractionsNotifierFamily._()
      : super(
          retry: null,
          name: r'postInteractionsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PostInteractionsNotifierProvider call(
    String postId,
  ) =>
      PostInteractionsNotifierProvider._(argument: postId, from: this);

  @override
  String toString() => r'postInteractionsProvider';
}

abstract class _$PostInteractionsNotifier
    extends $Notifier<PostInteractionState> {
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
