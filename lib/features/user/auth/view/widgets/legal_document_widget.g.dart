// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_document_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LegalAcceptance)
const legalAcceptanceProvider = LegalAcceptanceProvider._();

final class LegalAcceptanceProvider
    extends $NotifierProvider<LegalAcceptance, Map<String, bool>> {
  const LegalAcceptanceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'legalAcceptanceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$legalAcceptanceHash();

  @$internal
  @override
  LegalAcceptance create() => LegalAcceptance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$legalAcceptanceHash() => r'070ece5274f857906081770c80ea291ef1018ebd';

abstract class _$LegalAcceptance extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, bool>, Map<String, bool>>,
        Map<String, bool>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
