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
    extends $AsyncNotifierProvider<UserSettings, UserSettingsState> {
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

  @override
  bool operator ==(Object other) {
    return other is UserSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSettingsHash() => r'2e67a2f269e5a3c3ba36d344b0011c3fa9560537';

final class UserSettingsFamily extends $Family
    with
        $ClassFamilyOverride<UserSettings, AsyncValue<UserSettingsState>,
            UserSettingsState, FutureOr<UserSettingsState>, String> {
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

abstract class _$UserSettings extends $AsyncNotifier<UserSettingsState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<UserSettingsState> build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<AsyncValue<UserSettingsState>, UserSettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UserSettingsState>, UserSettingsState>,
        AsyncValue<UserSettingsState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
