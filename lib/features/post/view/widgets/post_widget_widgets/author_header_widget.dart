import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';

class AuthorHeaderWidget extends ConsumerWidget {
  final PostModel post;
  final String formattedTimestamp;
  final bool isCompact;
  final VoidCallback onProfileTap;
  final Widget postMenu;
  final Widget Function() buildLoadingHeader;

  const AuthorHeaderWidget({
    super.key,
    required this.post,
    required this.formattedTimestamp,
    required this.isCompact,
    required this.onProfileTap,
    required this.postMenu,
    required this.buildLoadingHeader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
        'Building author header for post ${post.id}, timestamp: $formattedTimestamp');

    final userAsyncValue = ref.watch(userProvider(post.authorId));

    return userAsyncValue.when(
      loading: () => buildLoadingHeader(),
      error: (error, stack) => Text('Error loading user',
          style: TextStyle(color: Colors.red.shade300)),
      data: (user) {
        if (user == null) return const Text('User not found');

        // Use appropriate profile image based on post privacy
        final profileImageUrl = post.isAlt
            ? (user.altProfileImageURL ?? user.profileImageURL)
            : user.profileImageURL;

        // Use appropriate name based on post privacy
        final displayName = post.isAlt
            ? (user.username)
            : '${user.firstName} ${user.lastName}'.trim();

        return Row(
          children: [
            // Profile image
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: isCompact ? 16 : 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                child: profileImageUrl == null || profileImageUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade400,
                        size: isCompact ? 16 : 20,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // User info
            Expanded(
              child: GestureDetector(
                onTap: onProfileTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Username
                    Row(
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 13 : 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (post.isAlt) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.lock,
                            size: 12,
                            //color: Colors.blue.shade400
                          ),
                        ],
                      ],
                    ),

                    // Timestamp - always show
                    Text(
                      formattedTimestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Post options menu
            postMenu,
          ],
        );
      },
    );
  }
}
