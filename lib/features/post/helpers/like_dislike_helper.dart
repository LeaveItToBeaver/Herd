import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../../user/view/providers/current_user_provider.dart';
import '../view/providers/post_provider.dart';

class LikeDislikeHelper {
  static void handleLikePost({
    required BuildContext context,
    required WidgetRef ref,
    required String postId,
    required bool isAlt,
    String? herdId,
  }) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId != null) {
      // Determine the correct feedType based on post properties
      final String feedType;
      if (herdId != null && herdId.isNotEmpty) {
        feedType = 'herd';
      } else if (isAlt) {
        feedType = 'alt';
      } else {
        feedType = 'public';
      }

      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: postId, isAlt: isAlt))
              .notifier)
          .likePost(userId, isAlt: isAlt, feedType: feedType, herdId: herdId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
    }
  }

  static void handleDislikePost({
    required BuildContext context,
    required WidgetRef ref,
    required String postId,
    required bool isAlt,
    String? herdId,
  }) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId != null) {
      // Determine the correct feedType based on post properties
      final String feedType;
      if (herdId != null && herdId.isNotEmpty) {
        feedType = 'herd';
      } else if (isAlt) {
        feedType = 'alt';
      } else {
        feedType = 'public';
      }

      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: postId, isAlt: isAlt))
              .notifier)
          .dislikePost(userId,
              isAlt: isAlt, feedType: feedType, herdId: herdId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to dislike posts.')),
      );
    }
  }

  static Widget buildLikeDislikeButtons({
    required BuildContext context,
    required WidgetRef ref,
    required int likes,
    required String postId,
    required bool isAlt,
    String? herdId,
  }) {
    final interactionState = ref.watch(postInteractionsWithPrivacyProvider(
        PostParams(id: postId, isAlt: isAlt)));

    // Always use the state-provided totalLikes value
    final displayLikes = interactionState.totalLikes;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                interactionState.isLiked
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                color: interactionState.isLiked ? Colors.green : Colors.grey),
            onPressed: () => handleLikePost(
              context: context,
              ref: ref,
              postId: postId,
              isAlt: isAlt,
              herdId: herdId,
            ),
          ),
          Text(displayLikes.toString()),
          IconButton(
            icon: Icon(
                interactionState.isDisliked
                    ? Icons.thumb_down
                    : Icons.thumb_down_outlined,
                color: interactionState.isDisliked ? Colors.red : Colors.grey),
            onPressed: () => handleDislikePost(
              context: context,
              ref: ref,
              postId: postId,
              isAlt: isAlt,
              herdId: herdId,
            ),
          ),
        ],
      ),
    );
  }
}
