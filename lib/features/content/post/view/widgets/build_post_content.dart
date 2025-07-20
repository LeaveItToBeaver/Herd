import 'package:flutter/material.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PostContentWidget extends StatelessWidget {
  final PostModel post;
  final bool isExpanded;
  final bool isCompact;
  final VoidCallback onToggleExpansion;
  final Widget Function(PostModel) buildMediaPreview;
  final bool shouldShowMedia;

  const PostContentWidget({
    super.key,
    required this.post,
    required this.isExpanded,
    required this.isCompact,
    required this.onToggleExpansion,
    required this.buildMediaPreview,
    required this.shouldShowMedia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if the post content is meant to be rich text
    if (post.isRichText) {
      if (post.mediaItems.isNotEmpty ||
          (post.mediaThumbnailURL != null &&
              post.mediaThumbnailURL!.isNotEmpty) ||
          (post.mediaURL != null && post.mediaURL!.isNotEmpty)) {
        // If it's rich text but has media, show the media preview
        return buildMediaPreview(post);
      }
      if (post.content.isNotEmpty) {
        return QuillViewerWidget(
          key: ValueKey('quill_viewer_${post.id}_widget'),
          jsonContent: post.content,
          source: RichTextSource.postWidget,
          isExpanded: isExpanded,
        );
      } else {
        // Handle empty rich text content
        return const SizedBox.shrink();
      }
    } else if (shouldShowMedia) {
      return buildMediaPreview(post);
    } else {
      // Fallback to rendering plain text if isRichText is false
      return _buildContentText(theme);
    }
  }

  Widget _buildContentText(ThemeData theme) {
    return GestureDetector(
      onTap: onToggleExpansion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              height: 1.4,
            ),
            maxLines: isExpanded ? null : (isCompact ? 3 : 4),
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (!isExpanded && post.content.length > (isCompact ? 100 : 150))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Read more',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
