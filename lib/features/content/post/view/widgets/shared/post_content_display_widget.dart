import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

class PostContentDisplay extends ConsumerStatefulWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final bool initialExpanded;
  final VoidCallback? onReadMore;
  final double? maxHeight;

  const PostContentDisplay({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
    this.initialExpanded = false,
    this.onReadMore,
    this.maxHeight,
  });

  @override
  ConsumerState<PostContentDisplay> createState() => _PostContentDisplayState();
}

class _PostContentDisplayState extends ConsumerState<PostContentDisplay> {
  late bool _isExpanded;
  bool _isNsfwRevealed = false;

  @override
  void initState() {
    super.initState();
    _isExpanded =
        widget.initialExpanded || widget.displayMode == HeaderDisplayMode.full;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // For pinned posts, use completely separate simple rendering to avoid constraint issues
    if (widget.displayMode == HeaderDisplayMode.pinned) {
      return _buildSimplePinnedPostContent(theme);
    }

    final isCompact = widget.displayMode == HeaderDisplayMode.compact;

    // Use select to only rebuild when specific user settings change
    final userAllowsNsfw = ref.watch(
      currentUserProvider.select((user) => user.allowNSFW ?? false),
    );
    final userPrefersBlur = ref.watch(
      currentUserProvider.select((user) => user.blurNSFW ?? true),
    );

    final shouldShowOverlay = widget.post.isNSFW &&
        userAllowsNsfw &&
        userPrefersBlur &&
        !_isNsfwRevealed;

    final shouldShowContent = !widget.post.isNSFW ||
        (userAllowsNsfw && (!userPrefersBlur || _isNsfwRevealed));

    // Wrap content in RepaintBoundary for isolation
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (widget.post.title != null && widget.post.title!.isNotEmpty) ...[
              Text(
                widget.post.title!,
                style: TextStyle(
                  fontSize: isCompact ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: isCompact && !_isExpanded ? 2 : null,
                overflow:
                    isCompact && !_isExpanded ? TextOverflow.ellipsis : null,
              ),
              SizedBox(height: isCompact ? 8 : 12),
            ],

            // Media content
            if (_hasMedia()) ...[
              RepaintBoundary(
                child: widget.post.isNSFW && !userAllowsNsfw
                    ? _buildNsfwHiddenMessage()
                    : shouldShowOverlay
                        ? PostNsfwOverlay(
                            onReveal: () {
                              setState(() {
                                _isNsfwRevealed = true;
                              });
                            },
                            height: isCompact ? 200 : 250,
                          )
                        : shouldShowContent
                            ? PostMediaDisplay(
                                post: widget.post,
                                displayMode: widget.displayMode,
                              )
                            : const SizedBox.shrink(),
              ),
              SizedBox(height: isCompact ? 8 : 16),
            ],

            // Text content
            if (widget.post.content.isNotEmpty) ...[
              RepaintBoundary(
                child: _buildTextContent(theme),
              ),
            ],

            // Tags
            if (widget.post.tags.isNotEmpty) ...[
              SizedBox(height: isCompact ? 8 : 12),
              RepaintBoundary(
                child: _buildTags(theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasMedia() {
    return widget.post.mediaItems.isNotEmpty ||
        (widget.post.mediaURL != null && widget.post.mediaURL!.isNotEmpty);
  }

  bool _shouldShowReadMore() {
    if (widget.post.isRichText) {
      // For rich text, check if the content has multiple operations or is lengthy
      try {
        final jsonData = jsonDecode(widget.post.content) as List;
        // If there are more than 3 operations, or the content looks substantial
        return jsonData.length > 3 || widget.post.content.length > 200;
      } catch (e) {
        // If parsing fails, fall back to length check
        return widget.post.content.length > 150;
      }
    } else {
      // For plain text, use the existing logic
      final isCompact = widget.displayMode == HeaderDisplayMode.compact;
      return widget.post.content.length > (isCompact ? 100 : 150);
    }
  }

  Widget _buildTextContent(ThemeData theme) {
    // For full screen, always show all content without constraints
    if (widget.displayMode == HeaderDisplayMode.full) {
      if (widget.post.isRichText) {
        return QuillViewerWidget(
          key: ValueKey('quill_viewer_${widget.post.id}_full'),
          jsonContent: widget.post.content,
          source: RichTextSource.postScreen,
        );
      } else {
        return Text(
          widget.post.content,
          style: const TextStyle(fontSize: 16),
        );
      }
    }

    // For pinned posts, use the simple pinned content method
    if (widget.displayMode == HeaderDisplayMode.pinned) {
      return _buildSimplePinnedPostContent(theme);
    }

    // For normal feed posts, use the original behavior
    return _buildFeedContent(theme);
  }

  Widget _buildSimplePinnedPostContent(ThemeData theme) {
    // For pinned posts, use QuillViewerWidget to properly display rich text and mentions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.post.title?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.post.title!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Use QuillViewerWidget for both rich text and plain text content
        if (widget.post.content.isNotEmpty) ...[
          Flexible(
            child: widget.post.isRichText
                ? QuillViewerWidget(
                    key: ValueKey('quill_viewer_${widget.post.id}_pinned'),
                    jsonContent: widget.post.content,
                    source: RichTextSource.pinnedPost,
                  )
                : Text(
                    widget.post.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                    overflow: TextOverflow.fade,
                  ),
          ),

          // Only show "Read more" if there's actually more content to show
          if (_shouldShowReadMore())
            GestureDetector(
              onTap: widget.onReadMore,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Read more',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildFeedContent(ThemeData theme) {
    final isCompact = widget.displayMode == HeaderDisplayMode.compact;

    if (widget.post.isRichText) {
      return RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RebuildDetector(
              name: 'QuillViewer-${widget.post.id}',
              child: QuillViewerWidget(
                key: ValueKey('quill_viewer_${widget.post.id}_feed'),
                jsonContent: widget.post.content,
                source: RichTextSource.postFeed,
                isExpanded: _isExpanded,
              ),
            ),
            if (!_isExpanded && _shouldShowReadMore())
              GestureDetector(
                onTap: widget.onReadMore ??
                    () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                child: Padding(
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
              ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: isCompact && widget.post.content.length > 150
            ? widget.onReadMore ??
                () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.content,
              style: TextStyle(
                fontSize: isCompact ? 14 : 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.4,
              ),
              maxLines: _isExpanded ? null : (isCompact ? 3 : 4),
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            if (!_isExpanded &&
                widget.post.content.length > (isCompact ? 100 : 150))
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

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: widget.post.tags.map((tag) {
        return GestureDetector(
          onTap: () {
            // TODO: Navigate to tag search
            debugPrint('Tag tapped: $tag');
          },
          child: Chip(
            label: Text(
              tag,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            backgroundColor:
                theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNsfwHiddenMessage() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 40, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'NSFW Content Hidden',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Adjust your settings to view',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
