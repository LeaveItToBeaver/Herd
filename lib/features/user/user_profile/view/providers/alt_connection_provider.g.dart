// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alt_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to get the count of a user's alt connections

@ProviderFor(altConnectionCount)
const altConnectionCountProvider = AltConnectionCountFamily._();

/// Provider to get the count of a user's alt connections

final class AltConnectionCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider to get the count of a user's alt connections
  const AltConnectionCountProvider._(
      {required AltConnectionCountFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'altConnectionCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$altConnectionCountHash();

  @override
  String toString() {
    return r'altConnectionCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return altConnectionCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AltConnectionCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$altConnectionCountHash() =>
    r'874cbfb614c2bf8064892000de8c821b0a8515fb';

/// Provider to get the count of a user's alt connections

final class AltConnectionCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const AltConnectionCountFamily._()
      : super(
          retry: null,
          name: r'altConnectionCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get the count of a user's alt connections

  AltConnectionCountProvider call(
    String userId,
  ) =>
      AltConnectionCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'altConnectionCountProvider';
}
