// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_bubble_toggle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to track if chat bubbles are enabled/disabled

@ProviderFor(ChatBubblesEnabled)
const chatBubblesEnabledProvider = ChatBubblesEnabledProvider._();

/// Provider to track if chat bubbles are enabled/disabled
final class ChatBubblesEnabledProvider
    extends $NotifierProvider<ChatBubblesEnabled, bool> {
  /// Provider to track if chat bubbles are enabled/disabled
  const ChatBubblesEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatBubblesEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatBubblesEnabledHash();

  @$internal
  @override
  ChatBubblesEnabled create() => ChatBubblesEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$chatBubblesEnabledHash() =>
    r'b459cb96716066e021c89f81c839276444fe91c6';

/// Provider to track if chat bubbles are enabled/disabled

abstract class _$ChatBubblesEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
