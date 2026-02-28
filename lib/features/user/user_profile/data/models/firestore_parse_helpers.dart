import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared helpers for parsing Firestore document values.
///
/// Used by [UserModel.fromMap] and any other model that reads
/// from Firestore documents with similar field types.
class FirestoreParseHelpers {
  const FirestoreParseHelpers._();

  /// Parse a Firestore [Timestamp] or ISO-8601 string into [DateTime].
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parse a dynamic list from Firestore into `List<String>`.
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((item) => item.toString()).toList();
    return [];
  }

  /// Parse a dynamic list of maps from Firestore into
  /// `List<Map<String, dynamic>>`.
  static List<Map<String, dynamic>> parseMapList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is Map
              ? Map<String, dynamic>.from(item)
              : <String, dynamic>{})
          .toList();
    }
    return [];
  }
}
