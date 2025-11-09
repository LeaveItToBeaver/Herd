// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Messages)
const messagesProvider = MessagesFamily._();

final class MessagesProvider
    extends $NotifierProvider<Messages, MessagesState> {
  const MessagesProvider._(
      {required MessagesFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'messagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Messages create() => Messages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessagesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessagesState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'4670f70bd9df28c5cc89fb74480a64b7fe2ec4aa';

final class MessagesFamily extends $Family
    with
        $ClassFamilyOverride<Messages, MessagesState, MessagesState,
            MessagesState, String> {
  const MessagesFamily._()
      : super(
          retry: null,
          name: r'messagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MessagesProvider call(
    String chatId,
  ) =>
      MessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'messagesProvider';
}

abstract class _$Messages extends $Notifier<MessagesState> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  MessagesState build(
    String chatId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<MessagesState, MessagesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MessagesState, MessagesState>,
        MessagesState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
