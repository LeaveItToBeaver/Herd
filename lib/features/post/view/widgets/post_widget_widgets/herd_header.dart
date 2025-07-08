import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';

class HerdHeaderWidget extends ConsumerWidget {
  final PostModel post;
  final String formattedTimestamp;
  final bool isCompact;
  final VoidCallback onProfileTap;
  final Widget postMenu;
  final Widget Function({required double width, required double height})
      buildShimmerText;

  const HerdHeaderWidget({
    super.key,
    required this.post,
    required this.formattedTimestamp,
    required this.isCompact,
    required this.onProfileTap,
    required this.postMenu,
    required this.buildShimmerText,
  });

  Widget _buildHerdProfileImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Icon(Icons.group,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      backgroundImage: NetworkImage(imageUrl),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
        'Building herd header for post ${post.id}, timestamp: $formattedTimestamp');

    final herdId = post.herdId!;
    final herdAsyncValue = ref.watch(herdProvider(herdId));
    final userAsyncValue = ref.watch(userProvider(post.authorId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Herd name row
        herdAsyncValue.when(
          loading: () => buildShimmerText(width: 150, height: 18),
          error: (_, __) => const Text('Unknown herd',
              style: TextStyle(fontStyle: FontStyle.italic)),
          data: (herd) {
            if (herd == null) return const Text('Unknown herd');

            return GestureDetector(
              onTap: () =>
                  context.pushNamed('herd', pathParameters: {'id': herdId}),
              child: Row(
                children: [
                  // Use the UserProfileImage widget for herd avatar
                  _buildHerdProfileImage(context, herd.profileImageURL),

                  const SizedBox(width: 12),

                  // Herd name (without h/ prefix)
                  Expanded(
                    child: Text(
                      herd.name, // No h/ prefix
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        //color: Colors.blue.shade700,
                        fontSize: isCompact ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Post menu
                  postMenu,
                ],
              ),
            );
          },
        ),

        // Author and timestamp row - always show
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Row(
            children: [
              userAsyncValue.when(
                loading: () => buildShimmerText(width: 100, height: 12),
                error: (_, __) => const Text('Unknown user',
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                data: (user) {
                  final displayName = user != null
                      ? (post.isAlt
                          ? (user.username)
                          : '${user.firstName} ${user.lastName}'.trim())
                      : 'Anonymous';

                  return GestureDetector(
                    onTap: () => user != null ? onProfileTap() : null,
                    child: Text(
                      'Posted by $displayName',
                      style: TextStyle(
                        //color: Colors.grey.shade600,
                        fontSize: isCompact ? 11 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                formattedTimestamp,
                style: TextStyle(
                  //color: Colors.grey.shade600,
                  fontSize: isCompact ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
