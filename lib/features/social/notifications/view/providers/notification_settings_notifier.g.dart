// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationSettings)
const notificationSettingsProvider = NotificationSettingsFamily._();

final class NotificationSettingsProvider extends $NotifierProvider<
    NotificationSettings, AsyncValue<NotificationSettingsModel?>> {
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
  NotificationSettings create() => NotificationSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<NotificationSettingsModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<NotificationSettingsModel?>>(value),
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
    r'685558e1cdb931a3060bea02a899b1f9e0ae29d9';

final class NotificationSettingsFamily extends $Family
    with
        $ClassFamilyOverride<
            NotificationSettings,
            AsyncValue<NotificationSettingsModel?>,
            AsyncValue<NotificationSettingsModel?>,
            AsyncValue<NotificationSettingsModel?>,
            String> {
  const NotificationSettingsFamily._()
      : super(
          retry: null,
          name: r'notificationSettingsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  NotificationSettingsProvider call(
    String userID,
  ) =>
      NotificationSettingsProvider._(argument: userID, from: this);

  @override
  String toString() => r'notificationSettingsProvider';
}

abstract class _$NotificationSettings
    extends $Notifier<AsyncValue<NotificationSettingsModel?>> {
  late final _$args = ref.$arg as String;
  String get userID => _$args;

  AsyncValue<NotificationSettingsModel?> build(
    String userID,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<NotificationSettingsModel?>,
        AsyncValue<NotificationSettingsModel?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NotificationSettingsModel?>,
            AsyncValue<NotificationSettingsModel?>>,
        AsyncValue<NotificationSettingsModel?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
