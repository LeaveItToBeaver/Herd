// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches data export status from the cloud function.
/// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.

@ProviderFor(dataExportStatus)
const dataExportStatusProvider = DataExportStatusFamily._();

/// Provider that fetches data export status from the cloud function.
/// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.

final class DataExportStatusProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider that fetches data export status from the cloud function.
  /// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.
  const DataExportStatusProvider._(
      {required DataExportStatusFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'dataExportStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dataExportStatusHash();

  @override
  String toString() {
    return r'dataExportStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return dataExportStatus(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DataExportStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dataExportStatusHash() => r'3ce74347531a6e5490e6cde76e045b1c66510fff';

/// Provider that fetches data export status from the cloud function.
/// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.

final class DataExportStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  const DataExportStatusFamily._()
      : super(
          retry: null,
          name: r'dataExportStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider that fetches data export status from the cloud function.
  /// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.

  DataExportStatusProvider call(
    String userId,
  ) =>
      DataExportStatusProvider._(argument: userId, from: this);

  @override
  String toString() => r'dataExportStatusProvider';
}
