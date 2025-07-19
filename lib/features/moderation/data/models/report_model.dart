import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_model.freezed.dart';

@freezed
abstract class ReportModel with _$ReportModel {
  const ReportModel._();

  const factory ReportModel({
    required String reportId,
    required String reportedBy, // userId
    required DateTime timestamp,
    required String targetId, // postId, commentId, or userId
    required ReportTargetType targetType,
    required ReportReason reason,
    String? description,
    @Default(ReportStatus.pending) ReportStatus status,
    String? reviewedBy, // moderator who reviewed
    DateTime? reviewedAt,
    String? resolution,
    Map<String, dynamic>? metadata, // Store additional context like herdId
  }) = _ReportModel;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      targetId: map['targetId'] ?? '',
      targetType: ReportTargetType.values.firstWhere(
        (e) => e.name == map['targetType'],
        orElse: () => ReportTargetType.post,
      ),
      reason: ReportReason.values.firstWhere(
        (e) => e.name == map['reason'],
        orElse: () => ReportReason.other,
      ),
      description: map['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      reviewedBy: map['reviewedBy'],
      reviewedAt: _parseDateTime(map['reviewedAt']),
      resolution: map['resolution'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reportedBy': reportedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'targetId': targetId,
      'targetType': targetType.name,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'resolution': resolution,
      'metadata': metadata,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

enum ReportTargetType { post, comment, user }

enum ReportReason { spam, harassment, inappropriate, misinformation, other }

enum ReportStatus { pending, reviewing, resolved, dismissed }
