// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_thread_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentThread)
const commentThreadProvider = CommentThreadFamily._();

final class CommentThreadProvider
    extends $NotifierProvider<CommentThread, CommentThreadState?> {
  const CommentThreadProvider._(
      {required CommentThreadFamily super.from,
      required ({
        String commentId,
        String? postId,
      })
          super.argument})
      : super(
          retry: null,
          name: r'commentThreadProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentThreadHash();

  @override
  String toString() {
    return r'commentThreadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CommentThread create() => CommentThread();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentThreadState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentThreadState?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentThreadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentThreadHash() => r'c1168d0628bdf5758aa1b2aa5780b645c57d6a11';

final class CommentThreadFamily extends $Family
    with
        $ClassFamilyOverride<
            CommentThread,
            CommentThreadState?,
            CommentThreadState?,
            CommentThreadState?,
            ({
              String commentId,
              String? postId,
            })> {
  const CommentThreadFamily._()
      : super(
          retry: null,
          name: r'commentThreadProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CommentThreadProvider call({
    required String commentId,
    String? postId,
  }) =>
      CommentThreadProvider._(argument: (
        commentId: commentId,
        postId: postId,
      ), from: this);

  @override
  String toString() => r'commentThreadProvider';
}

abstract class _$CommentThread extends $Notifier<CommentThreadState?> {
  late final _$args = ref.$arg as ({
    String commentId,
    String? postId,
  });
  String get commentId => _$args.commentId;
  String? get postId => _$args.postId;

  CommentThreadState? build({
    required String commentId,
    String? postId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      commentId: _$args.commentId,
      postId: _$args.postId,
    );
    final ref = this.ref as $Ref<CommentThreadState?, CommentThreadState?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CommentThreadState?, CommentThreadState?>,
        CommentThreadState?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
