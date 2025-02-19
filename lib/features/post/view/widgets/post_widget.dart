import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../user/data/models/user_model.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../providers/post_provider.dart';

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
    final isLikedAsyncValue = ref.watch(isPostLikedByUserProvider(widget.post.id));
    final isDislikedAsyncValue = ref.watch(isPostDislikedByUserProvider(widget.post.id));

    return GestureDetector(
      onTap: () => context.go('/post/${widget.post.id}'),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAsyncValue.when(
                loading: () => _buildLoadingHeader(),
                error: (error, stack) => Text('Error: $error'),
                data: (user) => _buildUserHeader(context, user, widget.post.authorId),
              ),

              const SizedBox(height: 12),

              if (widget.post.title != null)
                Text(
                  widget.post.title!,
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

              _buildActionButtons(ref, widget.post), // Pass AsyncValues and ref
            ],
          ),
        ),
      ),
    );
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

  Widget _buildUserHeader(BuildContext context, UserModel? user, String authorId) {
    if (user == null) {
      return const Text('User not found');
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/profile/$authorId'),
          child: CircleAvatar(
            radius: 25,
            backgroundImage: user.profileImageURL != null
                ? NetworkImage(user.profileImageURL!)
                : const AssetImage('assets/images/default_avatar.png')
            as ImageProvider,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context.go('/profile/$authorId'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.post.createdAt.toLocal().toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(WidgetRef ref, PostModel post) {
    final interactionState = ref.watch(postInteractionsProvider(widget.post.id));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoColumn(widget.post.likeCount - widget.post.dislikeCount, "Likes"),
        _buildInfoColumn(widget.post.commentCount, "Comments"),
        _buildIconButton(Icons.share_rounded, onPressed: () {}),
        _buildIconButton(Icons.comment_rounded, onPressed: () {}),
        Row(
          children: [
            _buildIconButton(
              interactionState.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: interactionState.isLiked ? Colors.green : null,
              onPressed: () => _handleLikePost(ref, widget.post.id),
            ),
            _buildIconButton(
              interactionState.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: interactionState.isDisliked ? Colors.red : null,
              onPressed: () => _handleDislikePost(ref, widget.post.id),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildInfoColumn(int count, String label) => Column(
    children: [
      Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(label),
    ],
  );

  Widget _buildIconButton(
      IconData icon, {
        Color? color,
        required VoidCallback onPressed,
      }) =>
      IconButton(
        icon: Icon(icon, color: color ?? Colors.black),
        onPressed: onPressed,
        enableFeedback: true,
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