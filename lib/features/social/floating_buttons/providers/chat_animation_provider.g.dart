// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_animation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to track when chat is closing and needs reverse animation

@ProviderFor(ChatClosingAnimation)
const chatClosingAnimationProvider = ChatClosingAnimationProvider._();

/// Provider to track when chat is closing and needs reverse animation
final class ChatClosingAnimationProvider
    extends $NotifierProvider<ChatClosingAnimation, String?> {
  /// Provider to track when chat is closing and needs reverse animation
  const ChatClosingAnimationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatClosingAnimationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$chatClosingAnimationHash();

  @$internal
  @override
  ChatClosingAnimation create() => ChatClosingAnimation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$chatClosingAnimationHash() =>
    r'6a4e17be16e7121e869694f550d9203a31ed0d16';

/// Provider to track when chat is closing and needs reverse animation

abstract class _$ChatClosingAnimation extends $Notifier<String?> {
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

/// Provider to track when herd is closing and needs reverse animation

@ProviderFor(HerdClosingAnimation)
const herdClosingAnimationProvider = HerdClosingAnimationProvider._();

/// Provider to track when herd is closing and needs reverse animation
final class HerdClosingAnimationProvider
    extends $NotifierProvider<HerdClosingAnimation, String?> {
  /// Provider to track when herd is closing and needs reverse animation
  const HerdClosingAnimationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'herdClosingAnimationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$herdClosingAnimationHash();

  @$internal
  @override
  HerdClosingAnimation create() => HerdClosingAnimation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$herdClosingAnimationHash() =>
    r'7618d60f182dd16b8c83503756d8ae88b098144e';

/// Provider to track when herd is closing and needs reverse animation

abstract class _$HerdClosingAnimation extends $Notifier<String?> {
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

/// Provider to track the animation callback for each bubble

@ProviderFor(BubbleAnimationCallback)
const bubbleAnimationCallbackProvider = BubbleAnimationCallbackProvider._();

/// Provider to track the animation callback for each bubble
final class BubbleAnimationCallbackProvider extends $NotifierProvider<
    BubbleAnimationCallback, Map<String, VoidCallback>> {
  /// Provider to track the animation callback for each bubble
  const BubbleAnimationCallbackProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bubbleAnimationCallbackProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bubbleAnimationCallbackHash();

  @$internal
  @override
  BubbleAnimationCallback create() => BubbleAnimationCallback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, VoidCallback> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, VoidCallback>>(value),
    );
  }
}

String _$bubbleAnimationCallbackHash() =>
    r'abc7804616aab83994c27fd5fa0dba9caf871d70';

/// Provider to track the animation callback for each bubble

abstract class _$BubbleAnimationCallback
    extends $Notifier<Map<String, VoidCallback>> {
  Map<String, VoidCallback> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<Map<String, VoidCallback>, Map<String, VoidCallback>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, VoidCallback>, Map<String, VoidCallback>>,
        Map<String, VoidCallback>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ExplosionReveal)
const explosionRevealProvider = ExplosionRevealProvider._();

final class ExplosionRevealProvider
    extends $NotifierProvider<ExplosionReveal, ExplosionRevealState?> {
  const ExplosionRevealProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'explosionRevealProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$explosionRevealHash();

  @$internal
  @override
  ExplosionReveal create() => ExplosionReveal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplosionRevealState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplosionRevealState?>(value),
    );
  }
}

String _$explosionRevealHash() => r'39e2f1651c12c4366e3410b23d730f9a044376de';

abstract class _$ExplosionReveal extends $Notifier<ExplosionRevealState?> {
  ExplosionRevealState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExplosionRevealState?, ExplosionRevealState?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ExplosionRevealState?, ExplosionRevealState?>,
        ExplosionRevealState?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
