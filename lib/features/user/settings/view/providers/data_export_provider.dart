import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

part 'data_export_provider.g.dart';

/// Provider that fetches data export status from the cloud function.
/// Returns a map with status, downloadUrl, fileSizeBytes, expiresAt, etc.
@riverpod
Future<Map<String, dynamic>> dataExportStatus(
  Ref ref,
  String userId,
) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getDataExportStatus(userId);
}
