// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for getting a specific chat by bubble ID

@ProviderFor(currentChat)
const currentChatProvider = CurrentChatFamily._();

/// Provider for getting a specific chat by bubble ID

final class CurrentChatProvider extends $FunctionalProvider<
        AsyncValue<ChatModel?>, ChatModel?, FutureOr<ChatModel?>>
    with $FutureModifier<ChatModel?>, $FutureProvider<ChatModel?> {
  /// Provider for getting a specific chat by bubble ID
  const CurrentChatProvider._(
      {required CurrentChatFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'currentChatProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentChatHash();

  @override
  String toString() {
    return r'currentChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChatModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatModel?> create(Ref ref) {
    final argument = this.argument as String;
    return currentChat(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentChatHash() => r'a65217bd1f565977e5864e6524eb368fddcbabcd';

/// Provider for getting a specific chat by bubble ID

final class CurrentChatFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChatModel?>, String> {
  const CurrentChatFamily._()
      : super(
          retry: null,
          name: r'currentChatProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for getting a specific chat by bubble ID

  CurrentChatProvider call(
    String bubbleId,
  ) =>
      CurrentChatProvider._(argument: bubbleId, from: this);

  @override
  String toString() => r'currentChatProvider';
}
