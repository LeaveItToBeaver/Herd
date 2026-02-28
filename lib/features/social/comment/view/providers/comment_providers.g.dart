// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentUpdate)
const commentUpdateProvider = CommentUpdateProvider._();

final class CommentUpdateProvider
    extends $NotifierProvider<CommentUpdate, int> {
  const CommentUpdateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentUpdateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentUpdateHash();

  @$internal
  @override
  CommentUpdate create() => CommentUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$commentUpdateHash() => r'f7fbf073663ecd459fee96ab68bd027389decc35';

abstract class _$CommentUpdate extends $Notifier<int> {
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

@ProviderFor(Comments)
const commentsProvider = CommentsFamily._();

final class CommentsProvider extends $NotifierProvider<Comments, CommentState> {
  const CommentsProvider._(
      {required CommentsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'commentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentsHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Comments create() => Comments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'03705edf2847367200a065867461765e27c1d5b8';

final class CommentsFamily extends $Family
    with
        $ClassFamilyOverride<Comments, CommentState, CommentState, CommentState,
            String> {
  const CommentsFamily._()
      : super(
          retry: null,
          name: r'commentsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CommentsProvider call(
    String postId,
  ) =>
      CommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentsProvider';
}

abstract class _$Comments extends $Notifier<CommentState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  CommentState build(
    String postId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
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
