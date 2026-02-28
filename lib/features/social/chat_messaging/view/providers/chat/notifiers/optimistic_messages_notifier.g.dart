// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimistic_messages_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages optimistic messages for a specific chat

@ProviderFor(OptimisticMessages)
const optimisticMessagesProvider = OptimisticMessagesFamily._();

/// Manages optimistic messages for a specific chat
final class OptimisticMessagesProvider
    extends $NotifierProvider<OptimisticMessages, Map<String, MessageModel>> {
  /// Manages optimistic messages for a specific chat
  const OptimisticMessagesProvider._(
      {required OptimisticMessagesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'optimisticMessagesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optimisticMessagesHash();

  @override
  String toString() {
    return r'optimisticMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OptimisticMessages create() => OptimisticMessages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, MessageModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, MessageModel>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OptimisticMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$optimisticMessagesHash() =>
    r'0362a64cd5f74bc53dbe3d33ac707b55da539e82';

/// Manages optimistic messages for a specific chat

final class OptimisticMessagesFamily extends $Family
    with
        $ClassFamilyOverride<OptimisticMessages, Map<String, MessageModel>,
            Map<String, MessageModel>, Map<String, MessageModel>, String> {
  const OptimisticMessagesFamily._()
      : super(
          retry: null,
          name: r'optimisticMessagesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Manages optimistic messages for a specific chat

  OptimisticMessagesProvider call(
    String chatId,
  ) =>
      OptimisticMessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'optimisticMessagesProvider';
}

/// Manages optimistic messages for a specific chat

abstract class _$OptimisticMessages
    extends $Notifier<Map<String, MessageModel>> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  Map<String, MessageModel> build(
    String chatId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<Map<String, MessageModel>, Map<String, MessageModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, MessageModel>, Map<String, MessageModel>>,
        Map<String, MessageModel>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
