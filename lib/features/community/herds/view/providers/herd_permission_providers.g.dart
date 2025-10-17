// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'herd_permission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to check if the current user is a member of a specific herd

@ProviderFor(isHerdMember)
const isHerdMemberProvider = IsHerdMemberFamily._();

/// Provider to check if the current user is a member of a specific herd

final class IsHerdMemberProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if the current user is a member of a specific herd
  const IsHerdMemberProvider._(
      {required IsHerdMemberFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'isHerdMemberProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isHerdMemberHash();

  @override
  String toString() {
    return r'isHerdMemberProvider'
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
    return isHerdMember(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsHerdMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isHerdMemberHash() => r'f0f27e3da409227b2c9084a760a438682e891ece';

/// Provider to check if the current user is a member of a specific herd

final class IsHerdMemberFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsHerdMemberFamily._()
      : super(
          retry: null,
          name: r'isHerdMemberProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if the current user is a member of a specific herd

  IsHerdMemberProvider call(
    String herdId,
  ) =>
      IsHerdMemberProvider._(argument: herdId, from: this);

  @override
  String toString() => r'isHerdMemberProvider';
}

/// Provider to check if the current user is a moderator of a specific herd

@ProviderFor(isHerdModerator)
const isHerdModeratorProvider = IsHerdModeratorFamily._();

/// Provider to check if the current user is a moderator of a specific herd

final class IsHerdModeratorProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if the current user is a moderator of a specific herd
  const IsHerdModeratorProvider._(
      {required IsHerdModeratorFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'isHerdModeratorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isHerdModeratorHash();

  @override
  String toString() {
    return r'isHerdModeratorProvider'
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
    return isHerdModerator(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsHerdModeratorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isHerdModeratorHash() => r'bd636fbebb6697a017998b802a09e788fffa9af4';

/// Provider to check if the current user is a moderator of a specific herd

final class IsHerdModeratorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsHerdModeratorFamily._()
      : super(
          retry: null,
          name: r'isHerdModeratorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to check if the current user is a moderator of a specific herd

  IsHerdModeratorProvider call(
    String herdId,
  ) =>
      IsHerdModeratorProvider._(argument: herdId, from: this);

  @override
  String toString() => r'isHerdModeratorProvider';
}

/// Provider to check if user is eligible to create herds

@ProviderFor(canCreateHerd)
const canCreateHerdProvider = CanCreateHerdProvider._();

/// Provider to check if user is eligible to create herds

final class CanCreateHerdProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if user is eligible to create herds
  const CanCreateHerdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canCreateHerdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canCreateHerdHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return canCreateHerd(ref);
  }
}

String _$canCreateHerdHash() => r'7867fc21c01fd64656014afac430a5e39e44e35a';
