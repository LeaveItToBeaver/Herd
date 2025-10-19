// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userStream)
const userStreamProvider = UserStreamFamily._();

final class UserStreamProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, Stream<UserModel?>>
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  const UserStreamProvider._(
      {required UserStreamFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userStreamHash();

  @override
  String toString() {
    return r'userStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return userStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userStreamHash() => r'0ca827ec06be7ae923e434691bcdcec02c597d2d';

final class UserStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserModel?>, String> {
  const UserStreamFamily._()
      : super(
          retry: null,
          name: r'userStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserStreamProvider call(
    String userId,
  ) =>
      UserStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'userStreamProvider';
}

@ProviderFor(user)
const userProvider = UserFamily._();

final class UserProvider extends $FunctionalProvider<AsyncValue<UserModel?>,
        UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  const UserProvider._(
      {required UserFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @override
  String toString() {
    return r'userProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return user(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHash() => r'c7486d1fd95cdc98dc140061764b585491a7bf34';

final class UserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserModel?>, String> {
  const UserFamily._()
      : super(
          retry: null,
          name: r'userProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserProvider call(
    String userId,
  ) =>
      UserProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProvider';
}

@ProviderFor(currentUserStream)
const currentUserStreamProvider = CurrentUserStreamProvider._();

final class CurrentUserStreamProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, Stream<UserModel?>>
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  const CurrentUserStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserStreamHash();

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    return currentUserStream(ref);
  }
}

String _$currentUserStreamHash() => r'3d27dc26d4c8332ec2aa52cd538c6c0dc944dec0';
