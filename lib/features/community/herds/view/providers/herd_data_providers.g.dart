// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'herd_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user's followed herds

@ProviderFor(userHerds)
const userHerdsProvider = UserHerdsProvider._();

/// Provider for user's followed herds

final class UserHerdsProvider extends $FunctionalProvider<
        AsyncValue<List<HerdModel>>, List<HerdModel>, Stream<List<HerdModel>>>
    with $FutureModifier<List<HerdModel>>, $StreamProvider<List<HerdModel>> {
  /// Provider for user's followed herds
  const UserHerdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userHerdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userHerdsHash();

  @$internal
  @override
  $StreamProviderElement<List<HerdModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<HerdModel>> create(Ref ref) {
    return userHerds(ref);
  }
}

String _$userHerdsHash() => r'05739e97b7d335d5b28e746d18cf7c1372b5e9eb';

/// Provider for a specific herd

@ProviderFor(herd)
const herdProvider = HerdFamily._();

/// Provider for a specific herd

final class HerdProvider extends $FunctionalProvider<AsyncValue<HerdModel?>,
        HerdModel?, FutureOr<HerdModel?>>
    with $FutureModifier<HerdModel?>, $FutureProvider<HerdModel?> {
  /// Provider for a specific herd
  const HerdProvider._(
      {required HerdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'herdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdHash();

  @override
  String toString() {
    return r'herdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HerdModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HerdModel?> create(Ref ref) {
    final argument = this.argument as String;
    return herd(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdHash() => r'ea7321b333840ce42b8f2025fbbfe2fbc56c198a';

/// Provider for a specific herd

final class HerdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HerdModel?>, String> {
  const HerdFamily._()
      : super(
          retry: null,
          name: r'herdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a specific herd

  HerdProvider call(
    String herdId,
  ) =>
      HerdProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdProvider';
}

/// Provider for a specific user's followed herds

@ProviderFor(profileUserHerds)
const profileUserHerdsProvider = ProfileUserHerdsFamily._();

/// Provider for a specific user's followed herds

final class ProfileUserHerdsProvider extends $FunctionalProvider<
        AsyncValue<List<HerdModel>>, List<HerdModel>, FutureOr<List<HerdModel>>>
    with $FutureModifier<List<HerdModel>>, $FutureProvider<List<HerdModel>> {
  /// Provider for a specific user's followed herds
  const ProfileUserHerdsProvider._(
      {required ProfileUserHerdsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'profileUserHerdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileUserHerdsHash();

  @override
  String toString() {
    return r'profileUserHerdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HerdModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<HerdModel>> create(Ref ref) {
    final argument = this.argument as String;
    return profileUserHerds(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileUserHerdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileUserHerdsHash() => r'97115be5cedc8ca980bdb22b2fc4cd4145c93c74';

/// Provider for a specific user's followed herds

final class ProfileUserHerdsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HerdModel>>, String> {
  const ProfileUserHerdsFamily._()
      : super(
          retry: null,
          name: r'profileUserHerdsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for a specific user's followed herds

  ProfileUserHerdsProvider call(
    String userId,
  ) =>
      ProfileUserHerdsProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileUserHerdsProvider';
}

/// Count of herds a specific user is in

@ProviderFor(userHerdCount)
const userHerdCountProvider = UserHerdCountFamily._();

/// Count of herds a specific user is in

final class UserHerdCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of herds a specific user is in
  const UserHerdCountProvider._(
      {required UserHerdCountFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userHerdCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userHerdCountHash();

  @override
  String toString() {
    return r'userHerdCountProvider'
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
    return userHerdCount(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserHerdCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHerdCountHash() => r'9b0a8dcb21fa0c25fb41d0c363df5ec6ac1226ca';

/// Count of herds a specific user is in

final class UserHerdCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const UserHerdCountFamily._()
      : super(
          retry: null,
          name: r'userHerdCountProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Count of herds a specific user is in

  UserHerdCountProvider call(
    String userId,
  ) =>
      UserHerdCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'userHerdCountProvider';
}

/// Stream provider for a specific herd's posts

@ProviderFor(herdPosts)
const herdPostsProvider = HerdPostsFamily._();

/// Stream provider for a specific herd's posts

final class HerdPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, Stream<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $StreamProvider<List<PostModel>> {
  /// Stream provider for a specific herd's posts
  const HerdPostsProvider._(
      {required HerdPostsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'herdPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdPostsHash();

  @override
  String toString() {
    return r'herdPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PostModel>> create(Ref ref) {
    final argument = this.argument as String;
    return herdPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdPostsHash() => r'9b811b65bec3b3b5ca3a37335eea0c1225f07049';

/// Stream provider for a specific herd's posts

final class HerdPostsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PostModel>>, String> {
  const HerdPostsFamily._()
      : super(
          retry: null,
          name: r'herdPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Stream provider for a specific herd's posts

  HerdPostsProvider call(
    String herdId,
  ) =>
      HerdPostsProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdPostsProvider';
}

/// Provider for herd members with detailed info

@ProviderFor(herdMembersWithInfo)
const herdMembersWithInfoProvider = HerdMembersWithInfoFamily._();

/// Provider for herd members with detailed info

final class HerdMembersWithInfoProvider extends $FunctionalProvider<
        AsyncValue<List<HerdMemberInfo>>,
        List<HerdMemberInfo>,
        FutureOr<List<HerdMemberInfo>>>
    with
        $FutureModifier<List<HerdMemberInfo>>,
        $FutureProvider<List<HerdMemberInfo>> {
  /// Provider for herd members with detailed info
  const HerdMembersWithInfoProvider._(
      {required HerdMembersWithInfoFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdMembersWithInfoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdMembersWithInfoHash();

  @override
  String toString() {
    return r'herdMembersWithInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HerdMemberInfo>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<HerdMemberInfo>> create(Ref ref) {
    final argument = this.argument as String;
    return herdMembersWithInfo(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdMembersWithInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdMembersWithInfoHash() =>
    r'2100933fe035f2c98aeb3e3b41f741ca56571484';

/// Provider for herd members with detailed info

final class HerdMembersWithInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HerdMemberInfo>>, String> {
  const HerdMembersWithInfoFamily._()
      : super(
          retry: null,
          name: r'herdMembersWithInfoProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for herd members with detailed info

  HerdMembersWithInfoProvider call(
    String herdId,
  ) =>
      HerdMembersWithInfoProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdMembersWithInfoProvider';
}

/// Provider for herd members - returns just the user IDs (legacy version)

@ProviderFor(herdMembers)
const herdMembersProvider = HerdMembersFamily._();

/// Provider for herd members - returns just the user IDs (legacy version)

final class HerdMembersProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for herd members - returns just the user IDs (legacy version)
  const HerdMembersProvider._(
      {required HerdMembersFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'herdMembersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdMembersHash();

  @override
  String toString() {
    return r'herdMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return herdMembers(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdMembersHash() => r'f8cf2242e3693eb5c72c28f26a795a1d8a3ce906';

/// Provider for herd members - returns just the user IDs (legacy version)

final class HerdMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  const HerdMembersFamily._()
      : super(
          retry: null,
          name: r'herdMembersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for herd members - returns just the user IDs (legacy version)

  HerdMembersProvider call(
    String herdId,
  ) =>
      HerdMembersProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdMembersProvider';
}

/// Provider for trending herds

@ProviderFor(trendingHerds)
const trendingHerdsProvider = TrendingHerdsProvider._();

/// Provider for trending herds

final class TrendingHerdsProvider extends $FunctionalProvider<
        AsyncValue<List<HerdModel>>, List<HerdModel>, FutureOr<List<HerdModel>>>
    with $FutureModifier<List<HerdModel>>, $FutureProvider<List<HerdModel>> {
  /// Provider for trending herds
  const TrendingHerdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'trendingHerdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$trendingHerdsHash();

  @$internal
  @override
  $FutureProviderElement<List<HerdModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<HerdModel>> create(Ref ref) {
    return trendingHerds(ref);
  }
}

String _$trendingHerdsHash() => r'7a4377c10453028425c5d4c612cdedb1d061c6e2';

/// Provider to track the current herd ID when viewing a herd screen

@ProviderFor(CurrentHerdId)
const currentHerdIdProvider = CurrentHerdIdProvider._();

/// Provider to track the current herd ID when viewing a herd screen
final class CurrentHerdIdProvider
    extends $NotifierProvider<CurrentHerdId, String?> {
  /// Provider to track the current herd ID when viewing a herd screen
  const CurrentHerdIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentHerdIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentHerdIdHash();

  @$internal
  @override
  CurrentHerdId create() => CurrentHerdId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentHerdIdHash() => r'7c340c0548cce637d5454dc1d06ccf28c1e2d171';

/// Provider to track the current herd ID when viewing a herd screen

abstract class _$CurrentHerdId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for pinned posts in a herd

@ProviderFor(herdPinnedPosts)
const herdPinnedPostsProvider = HerdPinnedPostsFamily._();

/// Provider for pinned posts in a herd

final class HerdPinnedPostsProvider extends $FunctionalProvider<
        AsyncValue<List<PostModel>>, List<PostModel>, FutureOr<List<PostModel>>>
    with $FutureModifier<List<PostModel>>, $FutureProvider<List<PostModel>> {
  /// Provider for pinned posts in a herd
  const HerdPinnedPostsProvider._(
      {required HerdPinnedPostsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'herdPinnedPostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdPinnedPostsHash();

  @override
  String toString() {
    return r'herdPinnedPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PostModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PostModel>> create(Ref ref) {
    final argument = this.argument as String;
    return herdPinnedPosts(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HerdPinnedPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$herdPinnedPostsHash() => r'768543a1761e5fe76972acc634ea08a28eff1487';

/// Provider for pinned posts in a herd

final class HerdPinnedPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PostModel>>, String> {
  const HerdPinnedPostsFamily._()
      : super(
          retry: null,
          name: r'herdPinnedPostsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for pinned posts in a herd

  HerdPinnedPostsProvider call(
    String herdId,
  ) =>
      HerdPinnedPostsProvider._(argument: herdId, from: this);

  @override
  String toString() => r'herdPinnedPostsProvider';
}
