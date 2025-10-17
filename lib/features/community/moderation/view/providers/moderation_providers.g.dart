// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(moderationRepository)
const moderationRepositoryProvider = ModerationRepositoryProvider._();

final class ModerationRepositoryProvider extends $FunctionalProvider<
    ModerationRepository,
    ModerationRepository,
    ModerationRepository> with $Provider<ModerationRepository> {
  const ModerationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'moderationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$moderationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ModerationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModerationRepository create(Ref ref) {
    return moderationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerationRepository>(value),
    );
  }
}

String _$moderationRepositoryHash() =>
    r'4fc5b2f4bbb9ac3c9901a08e77a233d9de77ac61';

@ProviderFor(herdModerationLog)
const herdModerationLogProvider = HerdModerationLogFamily._();

final class HerdModerationLogProvider extends $FunctionalProvider<
        AsyncValue<List<ModerationAction>>,
        List<ModerationAction>,
        Stream<List<ModerationAction>>>
    with
        $FutureModifier<List<ModerationAction>>,
        $StreamProvider<List<ModerationAction>> {
  const HerdModerationLogProvider._(
      {required HerdModerationLogFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdModerationLogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdModerationLogHash();

  @override
  String toString() {
    return r'herdModerationLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ModerationAction>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ModerationAction>> create(Ref ref) {
    final argument = this.argument as String;
    return herdModerationLog(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdModerationLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdModerationLogHash() => r'5f3b2272a871498a6a397887d61f68587464d406';

final class HerdModerationLogFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ModerationAction>>, String> {
  const HerdModerationLogFamily._()
      : super(
          retry: null,
          name: r'herdModerationLogProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  HerdModerationLogProvider call(
    String herdId,
  ) =>
      HerdModerationLogProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdModerationLogProvider';
}

@ProviderFor(herdPendingReports)
const herdPendingReportsProvider = HerdPendingReportsFamily._();

final class HerdPendingReportsProvider extends $FunctionalProvider<
        AsyncValue<List<ReportModel>>,
        List<ReportModel>,
        FutureOr<List<ReportModel>>>
    with
        $FutureModifier<List<ReportModel>>,
        $FutureProvider<List<ReportModel>> {
  const HerdPendingReportsProvider._(
      {required HerdPendingReportsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdPendingReportsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdPendingReportsHash();

  @override
  String toString() {
    return r'herdPendingReportsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReportModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReportModel>> create(Ref ref) {
    final argument = this.argument as String;
    return herdPendingReports(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdPendingReportsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdPendingReportsHash() =>
    r'bf0920b504a9ca5d112afc47f67fda06a6e5a420';

final class HerdPendingReportsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReportModel>>, String> {
  const HerdPendingReportsFamily._()
      : super(
          retry: null,
          name: r'herdPendingReportsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  HerdPendingReportsProvider call(
    String herdId,
  ) =>
      HerdPendingReportsProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdPendingReportsProvider';
}

@ProviderFor(isUserBanned)
const isUserBannedProvider = IsUserBannedFamily._();

final class IsUserBannedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsUserBannedProvider._(
      {required IsUserBannedFamily super.from,
      required ({
        String herdId,
        String userId,
      })
          super.argument})
      : super(
          retry: null,
          name: r'isUserBannedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isUserBannedHash();

  @override
  String toString() {
    return r'isUserBannedProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as ({
      String herdId,
      String userId,
    });
    return isUserBanned(
      ref,
      herdId: argument.herdId,
      userId: argument.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsUserBannedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isUserBannedHash() => r'121de8ae603d88db24e967dab05309c688f3242c';

final class IsUserBannedFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<bool>,
            ({
              String herdId,
              String userId,
            })> {
  const IsUserBannedFamily._()
      : super(
          retry: null,
          name: r'isUserBannedProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  IsUserBannedProvider call({
    required String herdId,
    required String userId,
  }) =>
      IsUserBannedProvider._(argument: (
        herdId: herdId,
        userId: userId,
      ), from: this);

  @override
  String toString() => r'isUserBannedProvider';
}

@ProviderFor(ModerationController)
const moderationControllerProvider = ModerationControllerProvider._();

final class ModerationControllerProvider
    extends $NotifierProvider<ModerationController, AsyncValue<void>> {
  const ModerationControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'moderationControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$moderationControllerHash();

  @$internal
  @override
  ModerationController create() => ModerationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$moderationControllerHash() =>
    r'06babc84141df541aa76396a211d35117a65a711';

abstract class _$ModerationController extends $Notifier<AsyncValue<void>> {
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
