// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_interaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentInteraction)
const commentInteractionProvider = CommentInteractionFamily._();

final class CommentInteractionProvider
    extends $NotifierProvider<CommentInteraction, CommentInteractionState> {
  const CommentInteractionProvider._(
      {required CommentInteractionFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'commentInteractionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentInteractionHash();

  @override
  String toString() {
    return r'commentInteractionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CommentInteraction create() => CommentInteraction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentInteractionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentInteractionHash() =>
    r'ebc076dac774b7f0989897c2b5ea571806fa0909';

final class CommentInteractionFamily extends $Family
    with
        $ClassFamilyOverride<
            CommentInteraction,
            CommentInteractionState,
            CommentInteractionState,
            CommentInteractionState,
            (
              String,
              String,
            )> {
  const CommentInteractionFamily._()
      : super(
          retry: null,
          name: r'commentInteractionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CommentInteractionProvider call(
    String commentId,
    String postId,
  ) =>
      CommentInteractionProvider._(argument: (
        commentId,
        postId,
      ), from: this);

  @override
  String toString() => r'commentInteractionProvider';
}

abstract class _$CommentInteraction extends $Notifier<CommentInteractionState> {
  late final _$args = ref.$arg as (
    String,
    String,
  );
  String get commentId => _$args.$1;
  String get postId => _$args.$2;

  CommentInteractionState build(
    String commentId,
    String postId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
    );
    final ref =
        this.ref as $Ref<CommentInteractionState, CommentInteractionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CommentInteractionState, CommentInteractionState>,
        CommentInteractionState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
