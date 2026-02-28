import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

/// Extensions for account status, deletion lifecycle, and premium features.
extension AccountStatusExtensions on UserModel {
  /// Whether the public account is active.
  bool get isActiveUser => isActive && accountStatus == 'active';

  /// Whether the user has an active premium subscription.
  bool get hasPremium =>
      isPremium &&
      (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));

  // ── Deletion lifecycle ──────────────────────────────────────────

  /// Whether the account has been marked for deletion.
  bool get isMarkedForDeletion => markedForDeleteAt != null;

  /// Days remaining until permanent deletion (30-day retention window).
  /// Returns `null` if not marked, `0` if past the window.
  int? get daysUntilDeletion {
    if (markedForDeleteAt == null) return null;
    final deletionDate = markedForDeleteAt!.add(const Duration(days: 30));
    final now = DateTime.now();
    if (deletionDate.isBefore(now)) return 0;
    return deletionDate.difference(now).inDays;
  }

  /// The date at which the account will be permanently deleted.
  DateTime? get permanentDeletionDate {
    if (markedForDeleteAt == null) return null;
    return markedForDeleteAt!.add(const Duration(days: 30));
  }
}
