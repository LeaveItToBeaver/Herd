import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../navigation/view/widgets/BottomNavPadding.dart';
import '../../data/models/post_model.dart';
import 'post_widget.dart';

enum PostListType {
  feed, // Regular feed with full-sized posts
  profile, // Profile view with more compact posts
  herd, // Herd view
  search, // Search results
}

class PostListWidget extends ConsumerStatefulWidget {
  final List<PostModel>? posts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasMorePosts;
  final ScrollController? scrollController;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final PostListType type;
  final String? emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final bool isRefreshing;

  const PostListWidget({
    super.key,
    this.posts,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasMorePosts = false,
    this.scrollController,
    this.onRefresh,
    this.onLoadMore,
    this.type = PostListType.feed,
    this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.isRefreshing = false,
  });

  @override
  ConsumerState<PostListWidget> createState() => _PostListWidgetState();
}

class _PostListWidgetState extends ConsumerState<PostListWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    debugPrint(
        'PostListWidget initialized with hasMorePosts=${widget.hasMorePosts}');
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    // GUARD: Check if the controller is attached before doing anything.
    if (!_scrollController.hasClients) {
      // Optionally log this, but it can be noisy during initial builds/rebuilds
      // debugPrint('ScrollListener: Controller not attached, skipping.');
      return;
    }

    final position = _scrollController.position; // Now safer to access
    final extentAfter = position.extentAfter;
    final threshold = position.maxScrollExtent * 0.2;

    final bool canLoadMore = widget.onLoadMore != null && widget.hasMorePosts;
    final bool notLoading = !widget.isLoading;
    final bool nearBottom =
        extentAfter < threshold && position.maxScrollExtent > 0;

    // Log current state during scroll events
    //Limit logging frequency if needed (e.g., only log near bottom)
    // if (position.maxScrollExtent > 0 &&
    //     extentAfter < position.maxScrollExtent * 0.5) {
    //   debugPrint(
    //       'ScrollListener Check: canLoadMore=$canLoadMore (hasMore=${widget.hasMorePosts}), notLoading=$notLoading, nearBottom=$nearBottom (extentAfter=${extentAfter.toStringAsFixed(1)}, threshold=${threshold.toStringAsFixed(1)})');
    // }

    if (canLoadMore && notLoading && nearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // GUARD: Re-check attachment and mounted status inside the callback
        if (!mounted || !_scrollController.hasClients) {
          debugPrint(
              'PostFrameCallback: Widget unmounted or controller detached, skipping load more.');
          return;
        }

        // Access position only after confirming attachment
        final currentPosition = _scrollController.position;
        final currentExtentAfter = currentPosition.extentAfter;
        // Re-calculate threshold based on potentially updated maxScrollExtent
        final currentThreshold = currentPosition.maxScrollExtent * 0.2;
        final currentNearBottom = currentExtentAfter < currentThreshold &&
            currentPosition.maxScrollExtent > 0;

        // Re-check all conditions before triggering
        if (widget.onLoadMore != null &&
            widget.hasMorePosts &&
            !widget
                .isLoading && // Re-check isLoading as state might have changed
            currentNearBottom) {
          debugPrint('PostListWidget: Triggering onLoadMore!');
          widget.onLoadMore!();
        } else if (mounted) {
          // Only log if still mounted
          debugPrint(
              'PostListWidget: PostFrameCallback check failed: hasMore=${widget.hasMorePosts}, isLoading=${widget.isLoading}, nearBottom=$currentNearBottom');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle initial loading state
    if (widget.posts == null && widget.isLoading) {
      return _buildLoadingSkeleton(theme);
    }

    // Handle error state
    if (widget.hasError) {
      return _buildErrorState(theme);
    }

    // Handle empty state
    if (widget.posts?.isEmpty ?? true) {
      return _buildEmptyState(theme);
    }

    // Main post list
    Widget listContent = ListView.builder(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: (widget.posts?.length ?? 0) +
          (widget.isLoading && widget.hasMorePosts ? 1 : 0) +
          1, // +1 for bottom padding
      itemBuilder: (context, index) {
        // Bottom loading indicator
        if (widget.isLoading &&
            widget.hasMorePosts &&
            index == widget.posts!.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          );
        }

        // Bottom padding as last item
        if (index ==
            (widget.posts?.length ?? 0) +
                (widget.isLoading && widget.hasMorePosts ? 1 : 0)) {
          return const BottomNavPadding(height: 80);
        }

        // Actual post items
        final post = widget.posts![index];

        // Determine if we should use compact layout
        final bool isCompact = widget.type == PostListType.profile ||
            widget.type == PostListType.search;

        return PostWidget(
          post: post,
          isCompact: isCompact,
        );
      },
    );

    // Wrap with RefreshIndicator if onRefresh callback is provided
    if (widget.onRefresh != null) {
      listContent = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: theme.colorScheme.primary,
        child: listContent,
      );
    }

    // Show a small loading indicator at the top during refresh
    if (widget.isRefreshing) {
      return Stack(
        children: [
          listContent,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    }

    return listContent;
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: _buildLoadingCard(theme),
        );
      },
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Content placeholder
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading posts',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.errorMessage ?? 'Please try again later',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (widget.onRefresh != null)
              ElevatedButton.icon(
                onPressed: () {
                  widget.onRefresh!();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    IconData icon;
    String message;

    // Customize empty state based on list type
    switch (widget.type) {
      case PostListType.feed:
        icon = Icons.dynamic_feed;
        message = widget.emptyMessage ?? 'No posts in your feed yet';
        break;
      case PostListType.profile:
        icon = Icons.account_circle;
        message = widget.emptyMessage ?? 'No posts yet';
        break;
      case PostListType.herd:
        icon = Icons.group;
        message = widget.emptyMessage ?? 'No posts in this herd yet';
        break;
      case PostListType.search:
        icon = Icons.search_off;
        message = widget.emptyMessage ?? 'No posts match your search';
        break;
    }

    return Center(
      child: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Icon(
              icon,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onEmptyAction != null &&
                widget.emptyActionLabel != null) ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: widget.onEmptyAction,
                  icon: const Icon(Icons.add),
                  label: Text(widget.emptyActionLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            const BottomNavPadding(height: 80),
          ],
        ),
      ),
    );
  }
}
