import 'package:freezed_annotation/freezed_annotation.dart';
import '../../enums/status_type.dart';
import '../../enums/status_privacy.dart';

part 'status_model.freezed.dart';
part 'status_model.g.dart';

@freezed
abstract class StatusModel with _$StatusModel {
  const StatusModel._();

  factory StatusModel({
    required String id,
    required String userId,
    String? userName,
    String? userProfileImage,
    required StatusType type,
    String? mediaUrl,
    String? text,
    String? caption,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default([]) List<String> viewedBy,
    @Default([]) List<String> allowedViewers, // For selected privacy
    @Default([]) List<String> excludedViewers, // For except selected privacy
    required StatusPrivacy privacy,
    @Default(false) bool isArchived,
    @Default(0) int viewCount,
    String? backgroundColor, // For text status
    String? textColor, // For text status
    String? fontStyle, // For text status
  }) = _StatusModel;

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);
}
