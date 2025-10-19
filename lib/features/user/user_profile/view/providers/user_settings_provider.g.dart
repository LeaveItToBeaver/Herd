// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentUserSettings)
const currentUserSettingsProvider = CurrentUserSettingsProvider._();

final class CurrentUserSettingsProvider
    extends $NotifierProvider<CurrentUserSettings, UserSettingsState> {
  const CurrentUserSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserSettingsHash();

  @$internal
  @override
  CurrentUserSettings create() => CurrentUserSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettingsState>(value),
    );
  }
}

String _$currentUserSettingsHash() =>
    r'2c1ab151a3e9ee6c2dbf9fbcced7e20d42412151';

abstract class _$CurrentUserSettings extends $Notifier<UserSettingsState> {
  UserSettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserSettingsState, UserSettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserSettingsState, UserSettingsState>,
        UserSettingsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
