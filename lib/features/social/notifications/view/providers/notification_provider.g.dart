// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Class-based notifier for notifications with proper Riverpod state management.
/// Setting [state] automatically triggers UI rebuilds.

@ProviderFor(Notification)
const notificationProvider = NotificationFamily._();

/// Class-based notifier for notifications with proper Riverpod state management.
/// Setting [state] automatically triggers UI rebuilds.
final class NotificationProvider
    extends $NotifierProvider<Notification, NotificationState> {
  /// Class-based notifier for notifications with proper Riverpod state management.
  /// Setting [state] automatically triggers UI rebuilds.
  const NotificationProvider._(
      {required NotificationFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'notificationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationHash();

  @override
  String toString() {
    return r'notificationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Notification create() => Notification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationHash() => r'4609e3e3d458b831cfa48f32c51b4edc57f4ee8f';

/// Class-based notifier for notifications with proper Riverpod state management.
/// Setting [state] automatically triggers UI rebuilds.

final class NotificationFamily extends $Family
    with
        $ClassFamilyOverride<Notification, NotificationState, NotificationState,
            NotificationState, String> {
  const NotificationFamily._()
      : super(
          retry: null,
          name: r'notificationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Class-based notifier for notifications with proper Riverpod state management.
  /// Setting [state] automatically triggers UI rebuilds.

  NotificationProvider call(
    String userId,
  ) =>
      NotificationProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationProvider';
}

/// Class-based notifier for notifications with proper Riverpod state management.
/// Setting [state] automatically triggers UI rebuilds.

abstract class _$Notification extends $Notifier<NotificationState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  NotificationState build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<NotificationState, NotificationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<NotificationState, NotificationState>,
        NotificationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Stream provider for real-time notifications

@ProviderFor(notificationStream)
const notificationStreamProvider = NotificationStreamFamily._();

/// Stream provider for real-time notifications

final class NotificationStreamProvider extends $FunctionalProvider<
        AsyncValue<List<NotificationModel>>,
        List<NotificationModel>,
        Stream<List<NotificationModel>>>
    with
        $FutureModifier<List<NotificationModel>>,
        $StreamProvider<List<NotificationModel>> {
  /// Stream provider for real-time notifications
  const NotificationStreamProvider._(
      {required NotificationStreamFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'notificationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationStreamHash();

  @override
  String toString() {
    return r'notificationStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NotificationModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<NotificationModel>> create(Ref ref) {
    final argument = this.argument as String;
    return notificationStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationStreamHash() =>
    r'b15cab97fac0653fc04df514cf865f71059a9f01';

/// Stream provider for real-time notifications

final class NotificationStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NotificationModel>>, String> {
  const NotificationStreamFamily._()
      : super(
          retry: null,
          name: r'notificationStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream provider for real-time notifications

  NotificationStreamProvider call(
    String userId,
  ) =>
      NotificationStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationStreamProvider';
}

/// Provider for unread notification count

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountFamily._();

/// Provider for unread notification count

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for unread notification count
  const UnreadNotificationCountProvider._(
      {required UnreadNotificationCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'unreadNotificationCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @override
  String toString() {
    return r'unreadNotificationCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return unreadNotificationCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadNotificationCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadNotificationCountHash() =>
    r'a728fb1f86736f3ba55716cf8ef8bc2028c9aa6d';

/// Provider for unread notification count

final class UnreadNotificationCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const UnreadNotificationCountFamily._()
      : super(
          retry: null,
          name: r'unreadNotificationCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for unread notification count

  UnreadNotificationCountProvider call(
    String userId,
  ) =>
      UnreadNotificationCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'unreadNotificationCountProvider';
}
