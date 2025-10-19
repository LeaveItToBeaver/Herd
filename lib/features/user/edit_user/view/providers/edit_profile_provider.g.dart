// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditProfile)
const editProfileProvider = EditProfileFamily._();

final class EditProfileProvider
    extends $NotifierProvider<EditProfile, EditProfileState> {
  const EditProfileProvider._(
      {required EditProfileFamily super.from,
      required UserModel super.argument})
      : super(
          retry: null,
          name: r'editProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editProfileHash();

  @override
  String toString() {
    return r'editProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditProfile create() => EditProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editProfileHash() => r'17722e10b8da7ddfb210b0306a2699fe40fa9321';

final class EditProfileFamily extends $Family
    with
        $ClassFamilyOverride<EditProfile, EditProfileState, EditProfileState,
            EditProfileState, UserModel> {
  const EditProfileFamily._()
      : super(
          retry: null,
          name: r'editProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EditProfileProvider call(
    UserModel user,
  ) =>
      EditProfileProvider._(argument: user, from: this);

  @override
  String toString() => r'editProfileProvider';
}

abstract class _$EditProfile extends $Notifier<EditProfileState> {
  late final _$args = ref.$arg as UserModel;
  UserModel get user => _$args;

  EditProfileState build(
    UserModel user,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<EditProfileState, EditProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<EditProfileState, EditProfileState>,
        EditProfileState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
