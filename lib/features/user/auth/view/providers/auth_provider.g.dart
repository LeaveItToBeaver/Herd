// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
const authProvider = AuthProvider._();

final class AuthProvider extends $NotifierProvider<Auth, User?> {
  const AuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$authHash() => r'f4175dbe7622c51be479ed0e7db348a02d90aebd';

abstract class _$Auth extends $Notifier<User?> {
  User? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<User?, User?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<User?, User?>, User?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AuthReady)
const authReadyProvider = AuthReadyProvider._();

final class AuthReadyProvider extends $NotifierProvider<AuthReady, bool> {
  const AuthReadyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authReadyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authReadyHash();

  @$internal
  @override
  AuthReady create() => AuthReady();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authReadyHash() => r'198a63b0b5c4b4b9eba12b6501d41e1238264307';

abstract class _$AuthReady extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(authStateChanges)
const authStateChangesProvider = AuthStateChangesProvider._();

final class AuthStateChangesProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  const AuthStateChangesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authStateChangesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'52dfd33379f6ac95e80410b5b47c5a347295a9d9';
