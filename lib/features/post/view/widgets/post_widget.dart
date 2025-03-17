import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../user/data/models/user_model.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../providers/post_provider.dart';
import '../providers/state/post_interaction_state.dart';

class PostWidget extends ConsumerStatefulWidget {
  final PostModel post;

  const PostWidget({super.key, required this.post});

  @override
  ConsumerState<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends ConsumerState<PostWidget> {
  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider(widget.post.authorId));
    final interactionState = ref.watch(postInteractionsProvider(widget.post.id));
    final currentUser = ref.watch(currentUserProvider);

    // Determine if the post is visible to the current user
    final bool canViewPost = !widget.post.isPrivate ||
        currentUser?.id == widget.post.authorId ||
        _userHasPrivateAccess(currentUser, widget.post.authorId);

    if (!canViewPost) {
      // Don't display private posts the user shouldn't see
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.pushNamed(
        'post',
        pathParameters: {'id': widget.post.id},
        queryParameters: {'isPrivate': widget.post.isPrivate.toString()},
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: widget.post.isPrivate
              ? BorderSide(color: Colors.blue.shade300, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy indicator bar
            if (widget.post.isPrivate)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      'Private Post',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsyncValue.when(
                    loading: () => _buildLoadingHeader(),
                    error: (error, stack) => Text('Error: $error'),
                    data: (user) => _buildUserHeader(context, user, widget.post.authorId, widget.post.isPrivate),
                  ),

                  const SizedBox(height: 12),

                  if (widget.post.title.isNotEmpty)
                    Text(
                      widget.post.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                  const SizedBox(height: 6),

                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.post.imageUrl!,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text('Failed to load image')),
                      ),
                    )
                  else
                    Text(
                      widget.post.content,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  _buildActionButtons(ref, widget.post, interactionState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder function - implement your actual access control logic
  bool _userHasPrivateAccess(UserModel? currentUser, String authorId) {
    // TODO: Implement actual private access check
    // For now, let's assume no one has private access except the author
    return false;
  }

  Widget _buildLoadingHeader() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/default_avatar.png'),
        ),
        SizedBox(width: 10),
        Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, UserModel? user, String authorId, bool isPrivate) {
    if (user == null) {
      return const Text('User not found');
    }

    // Use appropriate profile image based on post privacy
    final profileImageUrl = isPrivate
        ? (user.privateProfileImageURL ?? user.profileImageURL)
        : user.profileImageURL;

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pushNamed(
            isPrivate ? 'privateProfile' : 'publicProfile',
            pathParameters: {'id': authorId},
          ),
          child: CircleAvatar(
            radius: 22.0,
            backgroundColor: Colors.grey[200],
            // Only use NetworkImage if the URL exists and isn't empty
            backgroundImage: user.profileImageURL != null && user.profileImageURL!.isNotEmpty
                ? NetworkImage(user.profileImageURL!)
                : null,
            // Show placeholder icon if no image URL
            child: user.profileImageURL == null || user.profileImageURL!.isEmpty
                ? Icon(
              Icons.account_circle,
              color: Colors.grey[400],
              size: 22.0 * 2,
            )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => context.pushNamed(
              isPrivate ? 'privateProfile' : 'publicProfile',
              pathParameters: {'id': authorId},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
            children: [
                    Text(
                      isPrivate
                          ? (user.username)
                          : '${user.firstName} ${user.lastName}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isPrivate) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock, size: 14, color: Colors.blue),
                    ],
                  ],
                ),
                Text(
                  _formatTimestamp(widget.post.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Widget _buildActionButtons(WidgetRef ref, PostModel post, PostInteractionState interactionState) {
    // If the state hasn't been initialized and the user is logged in, initialize it
    if (!interactionState.isLoading &&
        !interactionState.isLiked &&
        !interactionState.isDisliked) {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(postInteractionsProvider(post.id).notifier).initializeState(userId);
        });
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          Icons.share_rounded,
          onPressed: post.isPrivate ? null : () {},
          enabled: !post.isPrivate,
        ),
        Row(
          children: [
            _buildIconButton(
              Icons.comment_rounded,
              onPressed: () {},
            ),
            _buildInfoColumn(post.commentCount),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              interactionState.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: interactionState.isLiked ? Colors.green : null,
              onPressed: () => _handleLikePost(ref, post.id),
            ),
            _buildInfoColumn(post.likeCount - post.dislikeCount),
            _buildIconButton(
              interactionState.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: interactionState.isDisliked ? Colors.red : null,
              onPressed: () => _handleDislikePost(ref, post.id),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(int count) => Column(
    children: [
      Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _buildIconButton(
      IconData icon, {
        Color? color,
        required VoidCallback? onPressed,
        bool enabled = true,
      }) =>
      IconButton(
        icon: Icon(icon, color: !enabled ? Colors.grey : (color ?? Colors.black)),
        onPressed: onPressed,
        enableFeedback: enabled,
      );

  void _handleLikePost(WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    if (userId != null) {
      ref.read(postInteractionsProvider(postId).notifier).likePost(userId);
    }
  }

  void _handleDislikePost(WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    if (userId != null) {
      ref.read(postInteractionsProvider(postId).notifier).dislikePost(userId);
    }
  }
}