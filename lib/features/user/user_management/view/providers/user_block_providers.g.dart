// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_block_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userBlockRepository)
const userBlockRepositoryProvider = UserBlockRepositoryProvider._();

final class UserBlockRepositoryProvider extends $FunctionalProvider<
    UserBlockRepository,
    UserBlockRepository,
    UserBlockRepository> with $Provider<UserBlockRepository> {
  const UserBlockRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userBlockRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userBlockRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserBlockRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserBlockRepository create(Ref ref) {
    return userBlockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserBlockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserBlockRepository>(value),
    );
  }
}

String _$userBlockRepositoryHash() =>
    r'434f702c490a5eb7de37c50e19bb4a27992dc7d7';

@ProviderFor(blockedUsers)
const blockedUsersProvider = BlockedUsersProvider._();

final class BlockedUsersProvider extends $FunctionalProvider<
        AsyncValue<List<UserBlockModel>>,
        List<UserBlockModel>,
        Stream<List<UserBlockModel>>>
    with
        $FutureModifier<List<UserBlockModel>>,
        $StreamProvider<List<UserBlockModel>> {
  const BlockedUsersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'blockedUsersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersHash();

  @$internal
  @override
  $StreamProviderElement<List<UserBlockModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<UserBlockModel>> create(Ref ref) {
    return blockedUsers(ref);
  }
}

String _$blockedUsersHash() => r'171185e58572c08babdae9e295a023dad6c29c1f';

@ProviderFor(blockedUsersWithLimit)
const blockedUsersWithLimitProvider = BlockedUsersWithLimitFamily._();

final class BlockedUsersWithLimitProvider extends $FunctionalProvider<
        AsyncValue<List<UserBlockModel>>,
        List<UserBlockModel>,
        Stream<List<UserBlockModel>>>
    with
        $FutureModifier<List<UserBlockModel>>,
        $StreamProvider<List<UserBlockModel>> {
  const BlockedUsersWithLimitProvider._(
      {required BlockedUsersWithLimitFamily super.from,
      required int super.argument})
      : super(
          retry: null,
          name: r'blockedUsersWithLimitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersWithLimitHash();

  @override
  String toString() {
    return r'blockedUsersWithLimitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<UserBlockModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<UserBlockModel>> create(Ref ref) {
    final argument = this.argument as int;
    return blockedUsersWithLimit(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BlockedUsersWithLimitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$blockedUsersWithLimitHash() =>
    r'a6dd307e07dc3b7ebdf42970e0ccadea6abb1a1d';

final class BlockedUsersWithLimitFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<UserBlockModel>>, int> {
  const BlockedUsersWithLimitFamily._()
      : super(
          retry: null,
          name: r'blockedUsersWithLimitProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BlockedUsersWithLimitProvider call(
    int limit,
  ) =>
      BlockedUsersWithLimitProvider._(argument: limit, from: this);

  @override
  String toString() => r'blockedUsersWithLimitProvider';
}

@ProviderFor(isUserBlocked)
const isUserBlockedProvider = IsUserBlockedFamily._();

final class IsUserBlockedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsUserBlockedProvider._(
      {required IsUserBlockedFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'isUserBlockedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isUserBlockedHash();

  @override
  String toString() {
    return r'isUserBlockedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isUserBlocked(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsUserBlockedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isUserBlockedHash() => r'a45b91ae6c7c58d7c16fc1959504c88189b983d4';

final class IsUserBlockedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsUserBlockedFamily._()
      : super(
          retry: null,
          name: r'isUserBlockedProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsUserBlockedProvider call(
    String targetUserId,
  ) =>
      IsUserBlockedProvider._(argument: targetUserId, from: this);

  @override
  String toString() => r'isUserBlockedProvider';
}

@ProviderFor(blockedUserDetails)
const blockedUserDetailsProvider = BlockedUserDetailsFamily._();

final class BlockedUserDetailsProvider extends $FunctionalProvider<
        AsyncValue<UserBlockModel?>, UserBlockModel?, FutureOr<UserBlockModel?>>
    with $FutureModifier<UserBlockModel?>, $FutureProvider<UserBlockModel?> {
  const BlockedUserDetailsProvider._(
      {required BlockedUserDetailsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'blockedUserDetailsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockedUserDetailsHash();

  @override
  String toString() {
    return r'blockedUserDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserBlockModel?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserBlockModel?> create(Ref ref) {
    final argument = this.argument as String;
    return blockedUserDetails(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BlockedUserDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$blockedUserDetailsHash() =>
    r'248687fc170e1e1786d1762c329494cc7fccdb10';

final class BlockedUserDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserBlockModel?>, String> {
  const BlockedUserDetailsFamily._()
      : super(
          retry: null,
          name: r'blockedUserDetailsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BlockedUserDetailsProvider call(
    String blockedUserId,
  ) =>
      BlockedUserDetailsProvider._(argument: blockedUserId, from: this);

  @override
  String toString() => r'blockedUserDetailsProvider';
}

@ProviderFor(blockedUsersCount)
const blockedUsersCountProvider = BlockedUsersCountProvider._();

final class BlockedUsersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const BlockedUsersCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'blockedUsersCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return blockedUsersCount(ref);
  }
}

String _$blockedUsersCountHash() => r'11f68749528d305fb9867e5098ac897f6949f531';

@ProviderFor(canUsersInteract)
const canUsersInteractProvider = CanUsersInteractFamily._();

final class CanUsersInteractProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const CanUsersInteractProvider._(
      {required CanUsersInteractFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'canUsersInteractProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canUsersInteractHash();

  @override
  String toString() {
    return r'canUsersInteractProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return canUsersInteract(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CanUsersInteractProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canUsersInteractHash() => r'4f460d328d3983368043ee28869a314e28bd2141';

final class CanUsersInteractFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const CanUsersInteractFamily._()
      : super(
          retry: null,
          name: r'canUsersInteractProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CanUsersInteractProvider call(
    String targetUserId,
  ) =>
      CanUsersInteractProvider._(argument: targetUserId, from: this);

  @override
  String toString() => r'canUsersInteractProvider';
}

@ProviderFor(BlockUserState)
const blockUserStateProvider = BlockUserStateProvider._();

final class BlockUserStateProvider
    extends $NotifierProvider<BlockUserState, AsyncValue<void>> {
  const BlockUserStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'blockUserStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockUserStateHash();

  @$internal
  @override
  BlockUserState create() => BlockUserState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$blockUserStateHash() => r'96a0a8c0e1254a59221257d66733d56037fbc742';

abstract class _$BlockUserState extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
