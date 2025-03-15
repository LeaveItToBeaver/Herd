import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../feed/providers/feed_type_provider.dart';
import '../models/user_model.dart';

extension ProfileNavigation on BuildContext {
  void navigateToUserProfile(String userId, WidgetRef ref) {
    final feedType = ref.read(currentFeedProvider);

    switch (feedType) {
      case FeedType.public:
        pushNamed('profile', pathParameters: {'id': userId});
        break;
      case FeedType.private:
      // If you're maintaining a single profile route:
        pushNamed('profile', pathParameters: {'id': userId});
        // Or if you create separate routes:
        // pushNamed('privateProfile', pathParameters: {'id': userId});
        break;
    }
  }

  void navigateToEditProfile(UserModel user, WidgetRef ref) {
    final feedType = ref.read(currentFeedProvider);

    switch (feedType) {
      case FeedType.public:
        pushNamed('editProfile', extra: {'user': user, 'isPublic': true});
        break;
      case FeedType.private:
        pushNamed('editProfile', extra: {'user': user, 'isPublic': false});
        break;
    }
  }
}