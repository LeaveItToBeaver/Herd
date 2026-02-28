// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileControllerNotifier)
const profileControllerProvider = ProfileControllerNotifierProvider._();

final class ProfileControllerNotifierProvider
    extends $AsyncNotifierProvider<ProfileControllerNotifier, ProfileState> {
  const ProfileControllerNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileControllerNotifierHash();

  @$internal
  @override
  ProfileControllerNotifier create() => ProfileControllerNotifier();
}

String _$profileControllerNotifierHash() =>
    r'6c300a49e98bc67739d4e3ec31b003096866f78e';

abstract class _$ProfileControllerNotifier
    extends $AsyncNotifier<ProfileState> {
  FutureOr<ProfileState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ProfileState>, ProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ProfileState>, ProfileState>,
        AsyncValue<ProfileState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
