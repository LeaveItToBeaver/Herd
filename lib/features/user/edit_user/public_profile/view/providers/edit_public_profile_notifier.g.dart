// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_public_profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditPublicProfile)
const editPublicProfileProvider = EditPublicProfileFamily._();

final class EditPublicProfileProvider
    extends $NotifierProvider<EditPublicProfile, EditPublicProfileState> {
  const EditPublicProfileProvider._(
      {required EditPublicProfileFamily super.from,
      required UserModel super.argument})
      : super(
          retry: null,
          name: r'editPublicProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editPublicProfileHash();

  @override
  String toString() {
    return r'editPublicProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditPublicProfile create() => EditPublicProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditPublicProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditPublicProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditPublicProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editPublicProfileHash() => r'cc22b1e8df8fb09c2680adf1201f73a3dbeb7a57';

final class EditPublicProfileFamily extends $Family
    with
        $ClassFamilyOverride<EditPublicProfile, EditPublicProfileState,
            EditPublicProfileState, EditPublicProfileState, UserModel> {
  const EditPublicProfileFamily._()
      : super(
          retry: null,
          name: r'editPublicProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EditPublicProfileProvider call(
    UserModel user,
  ) =>
      EditPublicProfileProvider._(argument: user, from: this);

  @override
  String toString() => r'editPublicProfileProvider';
}

abstract class _$EditPublicProfile extends $Notifier<EditPublicProfileState> {
  late final _$args = ref.$arg as UserModel;
  UserModel get user => _$args;

  EditPublicProfileState build(
    UserModel user,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<EditPublicProfileState, EditPublicProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<EditPublicProfileState, EditPublicProfileState>,
        EditPublicProfileState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
