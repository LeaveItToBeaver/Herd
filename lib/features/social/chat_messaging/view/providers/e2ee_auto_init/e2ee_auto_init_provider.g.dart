// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2ee_auto_init_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that automatically initializes E2EE keys when a user is authenticated

@ProviderFor(e2eeAutoInit)
const e2eeAutoInitProvider = E2eeAutoInitProvider._();

/// Provider that automatically initializes E2EE keys when a user is authenticated

final class E2eeAutoInitProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider that automatically initializes E2EE keys when a user is authenticated
  const E2eeAutoInitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'e2eeAutoInitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$e2eeAutoInitHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return e2eeAutoInit(ref);
  }
}

String _$e2eeAutoInitHash() => r'e22633383d6875e5e86b8e7c14fe6ec97925d99d';

/// Provider for getting E2EE key sync status

@ProviderFor(e2eeKeyStatus)
const e2eeKeyStatusProvider = E2eeKeyStatusFamily._();

/// Provider for getting E2EE key sync status

final class E2eeKeyStatusProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider for getting E2EE key sync status
  const E2eeKeyStatusProvider._(
      {required E2eeKeyStatusFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'e2eeKeyStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$e2eeKeyStatusHash();

  @override
  String toString() {
    return r'e2eeKeyStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return e2eeKeyStatus(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is E2eeKeyStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$e2eeKeyStatusHash() => r'0086ecf2306a2dc94ec957630ef8d50b15076f36';

/// Provider for getting E2EE key sync status

final class E2eeKeyStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  const E2eeKeyStatusFamily._()
      : super(
          retry: null,
          name: r'e2eeKeyStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for getting E2EE key sync status

  E2eeKeyStatusProvider call(
    String userId,
  ) =>
      E2eeKeyStatusProvider._(argument: userId, from: this);

  @override
  String toString() => r'e2eeKeyStatusProvider';
}

/// Provider for manually resetting E2EE keys

@ProviderFor(e2eeKeyReset)
const e2eeKeyResetProvider = E2eeKeyResetFamily._();

/// Provider for manually resetting E2EE keys

final class E2eeKeyResetProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Provider for manually resetting E2EE keys
  const E2eeKeyResetProvider._(
      {required E2eeKeyResetFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'e2eeKeyResetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$e2eeKeyResetHash();

  @override
  String toString() {
    return r'e2eeKeyResetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return e2eeKeyReset(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is E2eeKeyResetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$e2eeKeyResetHash() => r'006e6305ac7ca1f1cfd07da9370246ea9a0f3d6f';

/// Provider for manually resetting E2EE keys

final class E2eeKeyResetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const E2eeKeyResetFamily._()
      : super(
          retry: null,
          name: r'e2eeKeyResetProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for manually resetting E2EE keys

  E2eeKeyResetProvider call(
    String userId,
  ) =>
      E2eeKeyResetProvider._(argument: userId, from: this);

  @override
  String toString() => r'e2eeKeyResetProvider';
}
