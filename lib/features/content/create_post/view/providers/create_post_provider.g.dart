// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createPostRepository)
const createPostRepositoryProvider = CreatePostRepositoryProvider._();

final class CreatePostRepositoryProvider extends $FunctionalProvider<
    CreatePostRepository,
    CreatePostRepository,
    CreatePostRepository> with $Provider<CreatePostRepository> {
  const CreatePostRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createPostRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createPostRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreatePostRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreatePostRepository create(Ref ref) {
    return createPostRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostRepository>(value),
    );
  }
}

String _$createPostRepositoryHash() =>
    r'78466bbd0a90b712a24d5087354f551752e91a25';
