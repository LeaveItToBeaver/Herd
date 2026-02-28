// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_interaction_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageInteraction)
const messageInteractionProvider = MessageInteractionFamily._();

final class MessageInteractionProvider
    extends $NotifierProvider<MessageInteraction, MessageInteractionState> {
  const MessageInteractionProvider._(
      {required MessageInteractionFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'messageInteractionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageInteractionHash();

  @override
  String toString() {
    return r'messageInteractionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MessageInteraction create() => MessageInteraction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageInteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageInteractionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageInteractionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageInteractionHash() =>
    r'd9cf1eb7d2362d063aa6065af1bfda3a38a980b8';

final class MessageInteractionFamily extends $Family
    with
        $ClassFamilyOverride<MessageInteraction, MessageInteractionState,
            MessageInteractionState, MessageInteractionState, String> {
  const MessageInteractionFamily._()
      : super(
          retry: null,
          name: r'messageInteractionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MessageInteractionProvider call(
    String chatId,
  ) =>
      MessageInteractionProvider._(argument: chatId, from: this);

  @override
  String toString() => r'messageInteractionProvider';
}

abstract class _$MessageInteraction extends $Notifier<MessageInteractionState> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  MessageInteractionState build(
    String chatId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<MessageInteractionState, MessageInteractionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MessageInteractionState, MessageInteractionState>,
        MessageInteractionState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
