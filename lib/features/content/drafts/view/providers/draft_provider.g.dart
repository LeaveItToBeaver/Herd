// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(draftRepository)
const draftRepositoryProvider = DraftRepositoryProvider._();

final class DraftRepositoryProvider extends $FunctionalProvider<DraftRepository,
    DraftRepository, DraftRepository> with $Provider<DraftRepository> {
  const DraftRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'draftRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$draftRepositoryHash();

  @$internal
  @override
  $ProviderElement<DraftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftRepository create(Ref ref) {
    return draftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftRepository>(value),
    );
  }
}

String _$draftRepositoryHash() => r'fd5202ff167792e5a3da3c2d67dc8e11c9492b2c';

@ProviderFor(userDrafts)
const userDraftsProvider = UserDraftsProvider._();

final class UserDraftsProvider extends $FunctionalProvider<
        AsyncValue<List<DraftPostModel>>,
        List<DraftPostModel>,
        Stream<List<DraftPostModel>>>
    with
        $FutureModifier<List<DraftPostModel>>,
        $StreamProvider<List<DraftPostModel>> {
  const UserDraftsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userDraftsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userDraftsHash();

  @$internal
  @override
  $StreamProviderElement<List<DraftPostModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<DraftPostModel>> create(Ref ref) {
    return userDrafts(ref);
  }
}

String _$userDraftsHash() => r'3ca8e9e93db3017733bede98e2ab4acc66acb815';

@ProviderFor(draft)
const draftProvider = DraftFamily._();

final class DraftProvider extends $FunctionalProvider<
        AsyncValue<DraftPostModel?>, DraftPostModel?, FutureOr<DraftPostModel?>>
    with $FutureModifier<DraftPostModel?>, $FutureProvider<DraftPostModel?> {
  const DraftProvider._(
      {required DraftFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'draftProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$draftHash();

  @override
  String toString() {
    return r'draftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DraftPostModel?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DraftPostModel?> create(Ref ref) {
    final argument = this.argument as String;
    return draft(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DraftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$draftHash() => r'feed22a91f6ba9cb3be116df29e425452e802bab';

final class DraftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DraftPostModel?>, String> {
  const DraftFamily._()
      : super(
          retry: null,
          name: r'draftProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  DraftProvider call(
    String draftId,
  ) =>
      DraftProvider._(argument: draftId, from: this);

  @override
  String toString() => r'draftProvider';
}

@ProviderFor(DraftController)
const draftControllerProvider = DraftControllerProvider._();

final class DraftControllerProvider
    extends $NotifierProvider<DraftController, AsyncValue<void>> {
  const DraftControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'draftControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$draftControllerHash();

  @$internal
  @override
  DraftController create() => DraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$draftControllerHash() => r'8bea5bb8711c16202094eacacbd2637a5e6e20f4';

abstract class _$DraftController extends $Notifier<AsyncValue<void>> {
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

@ProviderFor(draftCount)
const draftCountProvider = DraftCountProvider._();

final class DraftCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  const DraftCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'draftCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$draftCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return draftCount(ref);
  }
}

String _$draftCountHash() => r'144a63f48d79478db929804bcc06080e8dcc1333';
