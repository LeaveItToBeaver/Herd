// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the notification notifier with userId parameter

@ProviderFor(notification)
const notificationProvider = NotificationFamily._();

/// Provider for the notification notifier with userId parameter

final class NotificationProvider extends $FunctionalProvider<
    NotificationNotifier,
    NotificationNotifier,
    NotificationNotifier> with $Provider<NotificationNotifier> {
  /// Provider for the notification notifier with userId parameter
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
  $ProviderElement<NotificationNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationNotifier create(Ref ref) {
    final argument = this.argument as String;
    return notification(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationNotifier>(value),
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

String _$notificationHash() => r'45a85dad375117e5926587e59ed70add8d7461f7';

/// Provider for the notification notifier with userId parameter

final class NotificationFamily extends $Family
    with $FunctionalFamilyOverride<NotificationNotifier, String> {
  const NotificationFamily._()
      : super(
          retry: null,
          name: r'notificationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for the notification notifier with userId parameter

  NotificationProvider call(
    String userId,
  ) =>
      NotificationProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationProvider';
}

/// Provider for notification settings with userId parameter

@ProviderFor(notificationSettings)
const notificationSettingsProvider = NotificationSettingsFamily._();

/// Provider for notification settings with userId parameter

final class NotificationSettingsProvider extends $FunctionalProvider<
    NotificationSettingsNotifier,
    NotificationSettingsNotifier,
    NotificationSettingsNotifier> with $Provider<NotificationSettingsNotifier> {
  /// Provider for notification settings with userId parameter
  const NotificationSettingsProvider._(
      {required NotificationSettingsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'notificationSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsHash();

  @override
  String toString() {
    return r'notificationSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<NotificationSettingsNotifier> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationSettingsNotifier create(Ref ref) {
    final argument = this.argument as String;
    return notificationSettings(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettingsNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettingsNotifier>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationSettingsHash() =>
    r'184899d0ca8eb95f368b5fdbd1dbb5a62682afe1';

/// Provider for notification settings with userId parameter

final class NotificationSettingsFamily extends $Family
    with $FunctionalFamilyOverride<NotificationSettingsNotifier, String> {
  const NotificationSettingsFamily._()
      : super(
          retry: null,
          name: r'notificationSettingsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for notification settings with userId parameter

  NotificationSettingsProvider call(
    String userId,
  ) =>
      NotificationSettingsProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationSettingsProvider';
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
