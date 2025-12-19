import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/community/moderation/data/repositories/moderation_repository.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

part 'pinned_post_management_providers.g.dart';

/// Loads a herd's pinned posts using parallel reads across the 3 possible
/// post locations (herdPosts, posts, altPosts).
@riverpod
Future<List<PostModel>> herdPinnedPostsBatch(Ref ref, String herdId) async {
  final herd = await ref.watch(herdProvider(herdId).future);
  if (herd == null || herd.pinnedPosts.isEmpty) return [];

  final List<PostModel> pinnedPosts = [];
  final firestore = FirebaseFirestore.instance;

  try {
    // Create a list of document references to read
    final List<DocumentReference> docRefs = [];

    for (final postId in herd.pinnedPosts) {
      // Add herd post reference
      docRefs.add(firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId));

      // Add public post reference
      docRefs.add(firestore.collection('posts').doc(postId));

      // Add alt post reference
      docRefs.add(firestore.collection('altPosts').doc(postId));
    }

    // Read all documents in parallel
    final futures = docRefs.map((ref) => ref.get()).toList();
    final snapshots = await Future.wait(futures);

    // Process the results
    for (int i = 0; i < herd.pinnedPosts.length; i++) {
      final postId = herd.pinnedPosts[i];

      // Check each location for this post (3 snapshots per post)
      final herdPostSnapshot = snapshots[i * 3];
      final publicPostSnapshot = snapshots[i * 3 + 1];
      final altPostSnapshot = snapshots[i * 3 + 2];

      if (herdPostSnapshot.exists) {
        pinnedPosts.add(
          PostModel.fromMap(
            herdPostSnapshot.id,
            herdPostSnapshot.data()! as Map<String, dynamic>,
          ),
        );
      } else if (publicPostSnapshot.exists) {
        pinnedPosts.add(
          PostModel.fromMap(
            publicPostSnapshot.id,
            publicPostSnapshot.data()! as Map<String, dynamic>,
          ),
        );
      } else if (altPostSnapshot.exists) {
        pinnedPosts.add(
          PostModel.fromMap(
            altPostSnapshot.id,
            altPostSnapshot.data()! as Map<String, dynamic>,
          ),
        );
      }
    }

    return pinnedPosts;
  } catch (e) {
    // Keep behavior consistent with previous implementation (fail soft).
    return [];
  }
}

@riverpod
ModerationRepository pinnedPostModerationRepository(Ref ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return ModerationRepository(FirebaseFirestore.instance, herdRepository);
}
