// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_alt_profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditAltProfile)
const editAltProfileProvider = EditAltProfileFamily._();

final class EditAltProfileProvider
    extends $NotifierProvider<EditAltProfile, EditAltProfileState> {
  const EditAltProfileProvider._(
      {required EditAltProfileFamily super.from,
      required UserModel super.argument})
      : super(
          retry: null,
          name: r'editAltProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editAltProfileHash();

  @override
  String toString() {
    return r'editAltProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditAltProfile create() => EditAltProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditAltProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditAltProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditAltProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editAltProfileHash() => r'3815c0ef094dbfa5b22b43abc217d90d7684d4dd';

final class EditAltProfileFamily extends $Family
    with
        $ClassFamilyOverride<EditAltProfile, EditAltProfileState,
            EditAltProfileState, EditAltProfileState, UserModel> {
  const EditAltProfileFamily._()
      : super(
          retry: null,
          name: r'editAltProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EditAltProfileProvider call(
    UserModel user,
  ) =>
      EditAltProfileProvider._(argument: user, from: this);

  @override
  String toString() => r'editAltProfileProvider';
}

abstract class _$EditAltProfile extends $Notifier<EditAltProfileState> {
  late final _$args = ref.$arg as UserModel;
  UserModel get user => _$args;

  EditAltProfileState build(
    UserModel user,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<EditAltProfileState, EditAltProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<EditAltProfileState, EditAltProfileState>,
        EditAltProfileState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
