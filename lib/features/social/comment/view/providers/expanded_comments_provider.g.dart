// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expanded_comments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpandedComments)
const expandedCommentsProvider = ExpandedCommentsProvider._();

final class ExpandedCommentsProvider
    extends $NotifierProvider<ExpandedComments, ExpandedCommentsState> {
  const ExpandedCommentsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expandedCommentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expandedCommentsHash();

  @$internal
  @override
  ExpandedComments create() => ExpandedComments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpandedCommentsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpandedCommentsState>(value),
    );
  }
}

String _$expandedCommentsHash() => r'247bc1f47ef5c575c9d5189ebf9f5f7b8a3b99ea';

abstract class _$ExpandedComments extends $Notifier<ExpandedCommentsState> {
  ExpandedCommentsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExpandedCommentsState, ExpandedCommentsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ExpandedCommentsState, ExpandedCommentsState>,
        ExpandedCommentsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
