// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreatePostController)
const createPostControllerProvider = CreatePostControllerProvider._();

final class CreatePostControllerProvider extends $NotifierProvider<
    CreatePostController, AsyncValue<CreatePostState>> {
  const CreatePostControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createPostControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createPostControllerHash();

  @$internal
  @override
  CreatePostController create() => CreatePostController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CreatePostState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CreatePostState>>(value),
    );
  }
}

String _$createPostControllerHash() =>
    r'f5e62cb6d64f30062991e8891accc1d2af458d4c';

abstract class _$CreatePostController
    extends $Notifier<AsyncValue<CreatePostState>> {
  AsyncValue<CreatePostState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<CreatePostState>, AsyncValue<CreatePostState>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CreatePostState>, AsyncValue<CreatePostState>>,
        AsyncValue<CreatePostState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
