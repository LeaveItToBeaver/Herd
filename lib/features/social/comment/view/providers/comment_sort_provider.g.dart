// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_sort_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentSort)
const commentSortProvider = CommentSortProvider._();

final class CommentSortProvider extends $NotifierProvider<CommentSort, String> {
  const CommentSortProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentSortProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentSortHash();

  @$internal
  @override
  CommentSort create() => CommentSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$commentSortHash() => r'b450dc47b14309ee224452bb38e2c76243a1b5ba';

abstract class _$CommentSort extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
