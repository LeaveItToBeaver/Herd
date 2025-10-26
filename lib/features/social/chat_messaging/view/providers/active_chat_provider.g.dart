// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveChatBubbles)
const activeChatBubblesProvider = ActiveChatBubblesProvider._();

final class ActiveChatBubblesProvider
    extends $NotifierProvider<ActiveChatBubbles, List<ChatModel>> {
  const ActiveChatBubblesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeChatBubblesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeChatBubblesHash();

  @$internal
  @override
  ActiveChatBubbles create() => ActiveChatBubbles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ChatModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChatModel>>(value),
    );
  }
}

String _$activeChatBubblesHash() => r'2810e51646f6299be68b9a2146394b929caac1fc';

abstract class _$ActiveChatBubbles extends $Notifier<List<ChatModel>> {
  List<ChatModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<ChatModel>, List<ChatModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<ChatModel>, List<ChatModel>>,
        List<ChatModel>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
