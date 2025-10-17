// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'herd_moderation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for banned users in a herd

@ProviderFor(bannedUsers)
const bannedUsersProvider = BannedUsersFamily._();

/// Provider for banned users in a herd

final class BannedUsersProvider extends $FunctionalProvider<
        AsyncValue<List<BannedUserInfo>>,
        List<BannedUserInfo>,
        FutureOr<List<BannedUserInfo>>>
    with
        $FutureModifier<List<BannedUserInfo>>,
        $FutureProvider<List<BannedUserInfo>> {
  /// Provider for banned users in a herd
  const BannedUsersProvider._(
      {required BannedUsersFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'bannedUsersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bannedUsersHash();

  @override
  String toString() {
    return r'bannedUsersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BannedUserInfo>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BannedUserInfo>> create(Ref ref) {
    final argument = this.argument as String;
    return bannedUsers(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BannedUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bannedUsersHash() => r'54ee6e1bc8462e46460f86bff7a792be65d78ef7';

/// Provider for banned users in a herd

final class BannedUsersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BannedUserInfo>>, String> {
  const BannedUsersFamily._()
      : super(
          retry: null,
          name: r'bannedUsersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for banned users in a herd

  BannedUsersProvider call(
    String herdId,
  ) =>
      BannedUsersProvider._(argument: herdId, from: this);

  @override
  String toString() => r'bannedUsersProvider';
}
