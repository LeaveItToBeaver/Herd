// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_animation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to track when chat is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle

@ProviderFor(ChatClosingAnimation)
const chatClosingAnimationProvider = ChatClosingAnimationProvider._();

/// Provider to track when chat is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle
final class ChatClosingAnimationProvider
    extends $NotifierProvider<ChatClosingAnimation, String?> {
  /// Provider to track when chat is closing and needs reverse animation
  /// Keep alive to persist state during animation lifecycle
  const ChatClosingAnimationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'chatClosingAnimationProvider',
          isAutoDispose: false,
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
    r'ce4c4adc55bcd82d3f1c2a43ac97080efe78e372';

/// Provider to track when chat is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle

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
/// Keep alive to persist state during animation lifecycle

@ProviderFor(HerdClosingAnimation)
const herdClosingAnimationProvider = HerdClosingAnimationProvider._();

/// Provider to track when herd is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle
final class HerdClosingAnimationProvider
    extends $NotifierProvider<HerdClosingAnimation, String?> {
  /// Provider to track when herd is closing and needs reverse animation
  /// Keep alive to persist state during animation lifecycle
  const HerdClosingAnimationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'herdClosingAnimationProvider',
          isAutoDispose: false,
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
    r'ad8b9bded27bdfa1a592fb4bce6b9055358688c6';

/// Provider to track when herd is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle

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
/// Keep alive to persist callbacks during overlay animation lifecycle

@ProviderFor(BubbleAnimationCallback)
const bubbleAnimationCallbackProvider = BubbleAnimationCallbackProvider._();

/// Provider to track the animation callback for each bubble
/// Keep alive to persist callbacks during overlay animation lifecycle
final class BubbleAnimationCallbackProvider extends $NotifierProvider<
    BubbleAnimationCallback, Map<String, VoidCallback>> {
  /// Provider to track the animation callback for each bubble
  /// Keep alive to persist callbacks during overlay animation lifecycle
  const BubbleAnimationCallbackProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bubbleAnimationCallbackProvider',
          isAutoDispose: false,
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
    r'f5788243b635a55b84bbebb00cea7fa289e766c0';

/// Provider to track the animation callback for each bubble
/// Keep alive to persist callbacks during overlay animation lifecycle

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

/// Keep alive to persist explosion reveal state during animation

@ProviderFor(ExplosionReveal)
const explosionRevealProvider = ExplosionRevealProvider._();

/// Keep alive to persist explosion reveal state during animation
final class ExplosionRevealProvider
    extends $NotifierProvider<ExplosionReveal, ExplosionRevealState?> {
  /// Keep alive to persist explosion reveal state during animation
  const ExplosionRevealProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'explosionRevealProvider',
          isAutoDispose: false,
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

String _$explosionRevealHash() => r'b574ec8fd312b0d7638288c6be0af9abf84681e3';

/// Keep alive to persist explosion reveal state during animation

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
