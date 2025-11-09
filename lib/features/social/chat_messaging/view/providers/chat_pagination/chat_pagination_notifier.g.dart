// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_pagination_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatPagination)
const chatPaginationProvider = ChatPaginationFamily._();

final class ChatPaginationProvider
    extends $NotifierProvider<ChatPagination, ChatPaginationState> {
  const ChatPaginationProvider._(
      {required ChatPaginationFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'chatPaginationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatPaginationHash();

  @override
  String toString() {
    return r'chatPaginationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatPagination create() => ChatPagination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatPaginationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatPaginationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatPaginationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatPaginationHash() => r'2baf86c4c903cccd5152724fd642c6af506efb8e';

final class ChatPaginationFamily extends $Family
    with
        $ClassFamilyOverride<ChatPagination, ChatPaginationState,
            ChatPaginationState, ChatPaginationState, String> {
  const ChatPaginationFamily._()
      : super(
          retry: null,
          name: r'chatPaginationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ChatPaginationProvider call(
    String chatId,
  ) =>
      ChatPaginationProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatPaginationProvider';
}

abstract class _$ChatPagination extends $Notifier<ChatPaginationState> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  ChatPaginationState build(
    String chatId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<ChatPaginationState, ChatPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ChatPaginationState, ChatPaginationState>,
        ChatPaginationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
