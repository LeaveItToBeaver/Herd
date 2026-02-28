import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

/// Extensions for public profile completeness, activity scoring,
/// engagement classification, and onboarding helpers.
extension UserProfileExtensions on UserModel {
  /// Full display name.
  String get fullName => '$firstName $lastName'.trim();

  /// Whether the public profile has all essential fields filled in.
  bool get isProfileComplete {
    if (firstName.isEmpty || lastName.isEmpty) return false;
    if (bio == null || bio!.isEmpty) return false;
    if (profileImageURL == null) return false;
    return true;
  }

  /// Map of profile fields that still need to be filled in (for onboarding).
  Map<String, String> getIncompleteFields() {
    final Map<String, String> incomplete = {};

    if (firstName.isEmpty) incomplete['firstName'] = 'First name is required';
    if (lastName.isEmpty) incomplete['lastName'] = 'Last name is required';
    if (bio == null || bio!.isEmpty) incomplete['bio'] = 'Add a short bio';
    if (profileImageURL == null) {
      incomplete['profileImage'] = 'Add a profile picture';
    }
    if (interests.isEmpty) {
      incomplete['interests'] = 'Add at least one interest';
    }

    return incomplete;
  }

  /// Activity level on a 1–10 scale based on content volume and recency.
  int get activityLevel {
    final now = DateTime.now();
    final lastActiveDate = lastActive ?? updatedAt ?? createdAt;
    if (lastActiveDate == null) return 1;

    final daysSinceActive = now.difference(lastActiveDate).inDays;

    int baseScore = 0;

    // Content score (max 5 points)
    final contentScore =
        ((totalPosts + totalComments) / 10).clamp(0, 5).floor();
    baseScore += contentScore;

    // Recency score (max 5 points)
    int recencyScore = 5;
    if (daysSinceActive > 1) recencyScore = 4;
    if (daysSinceActive > 7) recencyScore = 3;
    if (daysSinceActive > 30) recencyScore = 2;
    if (daysSinceActive > 90) recencyScore = 1;
    if (daysSinceActive > 180) recencyScore = 0;

    baseScore += recencyScore;

    return baseScore.clamp(1, 10);
  }

  /// Broad engagement archetype label.
  String get engagementType {
    final commentRatio = totalComments > 0
        ? totalComments / (totalPosts > 0 ? totalPosts : 1)
        : 0;
    final likeRatio =
        totalLikes > 0 ? totalLikes / (totalPosts + totalComments) : 0;

    if (totalPosts > 50 && commentRatio < 1) {
      return 'Creator';
    } else if (commentRatio > 5) {
      return 'Commenter';
    } else if (likeRatio > 10 && totalPosts < 10) {
      return 'Observer';
    } else if (followersList.length > followingList.length * 2) {
      return 'Influencer';
    } else {
      return 'Balanced';
    }
  }

  /// Whether a user can safely be deleted (no content / not a moderator).
  bool get canBeDeleted {
    bool hasContent = totalPosts > 0 || totalComments > 0;
    bool hasAltContent = altTotalPosts > 0 || altTotalComments > 0;
    bool isGroupModerator =
        moderatedGroups.isNotEmpty || altModeratedGroups.isNotEmpty;

    return !hasContent && !hasAltContent && !isGroupModerator;
  }

  /// Pinned-post helpers ─────────────────────────────────────────────

  bool canPinMorePosts({bool isAlt = false}) {
    final currentPinned = isAlt ? altPinnedPosts : pinnedPosts;
    return currentPinned.length < 5;
  }

  bool isPostPinned(String postId, {bool isAlt = false}) {
    final currentPinned = isAlt ? altPinnedPosts : pinnedPosts;
    return currentPinned.contains(postId);
  }
}
