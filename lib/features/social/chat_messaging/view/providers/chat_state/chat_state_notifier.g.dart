// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatStateNotifier)
const chatStateProvider = ChatStateNotifierProvider._();

final class ChatStateNotifierProvider
    extends $NotifierProvider<ChatStateNotifier, ChatState> {
  const ChatStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatStateNotifierHash();

  @$internal
  @override
  ChatStateNotifier create() => ChatStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }
}

String _$chatStateNotifierHash() => r'4b40a7926aa21b3310ba4b60aebe8513cdbedf69';

abstract class _$ChatStateNotifier extends $Notifier<ChatState> {
  ChatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ChatState, ChatState>, ChatState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
