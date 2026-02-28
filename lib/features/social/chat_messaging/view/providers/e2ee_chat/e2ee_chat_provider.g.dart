// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2ee_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Automatically initializes E2EE identity keys when user is authenticated

@ProviderFor(e2eeInit)
const e2eeInitProvider = E2eeInitProvider._();

/// Automatically initializes E2EE identity keys when user is authenticated

final class E2eeInitProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Automatically initializes E2EE identity keys when user is authenticated
  const E2eeInitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'e2eeInitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$e2eeInitHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return e2eeInit(ref);
  }
}

String _$e2eeInitHash() => r'd7ca27cc506d7815ea4dd46c1ecb5af066d3dbcd';

/// Provider that can be consumed in the app to ensure E2EE is initialized

@ProviderFor(e2eeStatus)
const e2eeStatusProvider = E2eeStatusProvider._();

/// Provider that can be consumed in the app to ensure E2EE is initialized

final class E2eeStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider that can be consumed in the app to ensure E2EE is initialized
  const E2eeStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'e2eeStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$e2eeStatusHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return e2eeStatus(ref);
  }
}

String _$e2eeStatusHash() => r'165dc438d12b55e4472e3532430c0058138bde9e';

/// Initialize E2EE for a specific user

@ProviderFor(initializeE2ee)
const initializeE2eeProvider = InitializeE2eeFamily._();

/// Initialize E2EE for a specific user

final class InitializeE2eeProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Initialize E2EE for a specific user
  const InitializeE2eeProvider._(
      {required InitializeE2eeFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'initializeE2eeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$initializeE2eeHash();

  @override
  String toString() {
    return r'initializeE2eeProvider'
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
    return initializeE2ee(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InitializeE2eeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$initializeE2eeHash() => r'95438751a620cd57a5fc11f7b60ba79c95df85f0';

/// Initialize E2EE for a specific user

final class InitializeE2eeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const InitializeE2eeFamily._()
      : super(
          retry: null,
          name: r'initializeE2eeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Initialize E2EE for a specific user

  InitializeE2eeProvider call(
    String userId,
  ) =>
      InitializeE2eeProvider._(argument: userId, from: this);

  @override
  String toString() => r'initializeE2eeProvider';
}
