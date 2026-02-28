// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentUpdateCounter)
const commentUpdateCounterProvider = CommentUpdateCounterProvider._();

final class CommentUpdateCounterProvider
    extends $NotifierProvider<CommentUpdateCounter, int> {
  const CommentUpdateCounterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentUpdateCounterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentUpdateCounterHash();

  @$internal
  @override
  CommentUpdateCounter create() => CommentUpdateCounter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$commentUpdateCounterHash() =>
    r'd6dd1ae03fcd9e70ca2705f79df2471ba9663a00';

abstract class _$CommentUpdateCounter extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CommentsUpdate)
const commentsUpdateProvider = CommentsUpdateFamily._();

final class CommentsUpdateProvider
    extends $NotifierProvider<CommentsUpdate, CommentState> {
  const CommentsUpdateProvider._(
      {required CommentsUpdateFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'commentsUpdateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentsUpdateHash();

  @override
  String toString() {
    return r'commentsUpdateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CommentsUpdate create() => CommentsUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsUpdateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsUpdateHash() => r'0e2ea3b158c3a8233bf159061a4cb2aa746e6428';

final class CommentsUpdateFamily extends $Family
    with
        $ClassFamilyOverride<
            CommentsUpdate,
            CommentState,
            CommentState,
            CommentState,
            (
              String,
              String,
            )> {
  const CommentsUpdateFamily._()
      : super(
          retry: null,
          name: r'commentsUpdateProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CommentsUpdateProvider call(
    String postId,
    String sortBy,
  ) =>
      CommentsUpdateProvider._(argument: (
        postId,
        sortBy,
      ), from: this);

  @override
  String toString() => r'commentsUpdateProvider';
}

abstract class _$CommentsUpdate extends $Notifier<CommentState> {
  late final _$args = ref.$arg as (
    String,
    String,
  );
  String get postId => _$args.$1;
  String get sortBy => _$args.$2;

  CommentState build(
    String postId,
    String sortBy,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
    );
    final ref = this.ref as $Ref<CommentState, CommentState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CommentState, CommentState>,
        CommentState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
