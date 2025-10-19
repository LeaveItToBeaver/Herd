// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserSettings)
const userSettingsProvider = UserSettingsFamily._();

final class UserSettingsProvider
    extends $NotifierProvider<UserSettings, UserSettingsState> {
  const UserSettingsProvider._(
      {required UserSettingsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSettingsHash();

  @override
  String toString() {
    return r'userSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserSettings create() => UserSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettingsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSettingsHash() => r'68eb2f64fa63f8b7e53b4064f7e4908486cb966c';

final class UserSettingsFamily extends $Family
    with
        $ClassFamilyOverride<UserSettings, UserSettingsState, UserSettingsState,
            UserSettingsState, String> {
  const UserSettingsFamily._()
      : super(
          retry: null,
          name: r'userSettingsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserSettingsProvider call(
    String userId,
  ) =>
      UserSettingsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userSettingsProvider';
}

abstract class _$UserSettings extends $Notifier<UserSettingsState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  UserSettingsState build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<UserSettingsState, UserSettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserSettingsState, UserSettingsState>,
        UserSettingsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
