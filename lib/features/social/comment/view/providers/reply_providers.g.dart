// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Replies)
const repliesProvider = RepliesFamily._();

final class RepliesProvider extends $NotifierProvider<Replies, ReplyState> {
  const RepliesProvider._(
      {required RepliesFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'repliesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$repliesHash();

  @override
  String toString() {
    return r'repliesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Replies create() => Replies();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplyState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RepliesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$repliesHash() => r'09f855d5334dd32f2b8583f1027be2d0dde64aba';

final class RepliesFamily extends $Family
    with
        $ClassFamilyOverride<Replies, ReplyState, ReplyState, ReplyState,
            String> {
  const RepliesFamily._()
      : super(
          retry: null,
          name: r'repliesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  RepliesProvider call(
    String postId,
  ) =>
      RepliesProvider._(argument: postId, from: this);

  @override
  String toString() => r'repliesProvider';
}

abstract class _$Replies extends $Notifier<ReplyState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  ReplyState build(
    String postId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<ReplyState, ReplyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ReplyState, ReplyState>, ReplyState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
