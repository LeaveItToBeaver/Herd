// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'herd_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Basic repository provider for herd operations

@ProviderFor(herdRepository)
const herdRepositoryProvider = HerdRepositoryProvider._();

/// Basic repository provider for herd operations

final class HerdRepositoryProvider
    extends $FunctionalProvider<HerdRepository, HerdRepository, HerdRepository>
    with $Provider<HerdRepository> {
  /// Basic repository provider for herd operations
  const HerdRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'herdRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdRepositoryHash();

  @$internal
  @override
  $ProviderElement<HerdRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HerdRepository create(Ref ref) {
    return herdRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HerdRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HerdRepository>(value),
    );
  }
}

String _$herdRepositoryHash() => r'a88008cdd0c4e97a55f0ac15399363cb36148e85';
