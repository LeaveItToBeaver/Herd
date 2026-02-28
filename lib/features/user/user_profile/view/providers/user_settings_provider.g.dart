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
    extends $AsyncNotifierProvider<CurrentUserSettings, UserSettingsState> {
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
}

String _$currentUserSettingsHash() =>
    r'd7aef065c905d7fdcb1f8496161ee72191b3907c';

abstract class _$CurrentUserSettings extends $AsyncNotifier<UserSettingsState> {
  FutureOr<UserSettingsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
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
