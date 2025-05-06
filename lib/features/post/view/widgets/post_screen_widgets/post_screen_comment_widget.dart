import 'package:flutter/material.dart';
import 'package:herdapp/features/comment/view/widgets/comment_list_widget.dart';

class PostCommentSection extends StatelessWidget {
  final String postId;
  final bool isAltPost;

  const PostCommentSection({
    super.key,
    required this.postId,
    required this.isAltPost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments section header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Comments",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // Comments list widget
        RepaintBoundary(
          child: CommentListWidget(
            postId: postId,
            isAltPost: isAltPost,
          ),
        ),
      ],
    );
  }
}
