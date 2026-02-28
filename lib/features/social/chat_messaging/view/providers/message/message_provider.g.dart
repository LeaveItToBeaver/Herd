// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(message)
const messageProvider = MessageFamily._();

final class MessageProvider extends $FunctionalProvider<
        AsyncValue<MessageModel?>, MessageModel?, Stream<MessageModel?>>
    with $FutureModifier<MessageModel?>, $StreamProvider<MessageModel?> {
  const MessageProvider._(
      {required MessageFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'messageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messageHash();

  @override
  String toString() {
    return r'messageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MessageModel?> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<MessageModel?> create(Ref ref) {
    final argument = this.argument as String;
    return message(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageHash() => r'740fa1f99959d45cd01bb9d4f0eb09abe82990a1';

final class MessageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MessageModel?>, String> {
  const MessageFamily._()
      : super(
          retry: null,
          name: r'messageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MessageProvider call(
    String chatMessageKey,
  ) =>
      MessageProvider._(argument: chatMessageKey, from: this);

  @override
  String toString() => r'messageProvider';
}
