import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/post/view/widgets/post_widget.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../../../../herds/view/providers/herd_providers.dart';
import '../../../../navigation/view/widgets/BottomNavPadding.dart';
import '../../../../post/view/widgets/post_list_widget.dart';
import '../providers/alt_feed_provider.dart';

class AltFeedScreen extends ConsumerStatefulWidget {
  const AltFeedScreen({super.key});

  @override
  ConsumerState<AltFeedScreen> createState() => _AltFeedScreenState();
}

class _AltFeedScreenState extends ConsumerState<AltFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshVisiblePostInteractions();
  }

  void _refreshVisiblePostInteractions() {
    // Later, we must implement a central interaction store
    // to avoid multiple calls to the same post
    if (!mounted) return;

    Future.microtask(() {
      final state = ref.read(altFeedControllerProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync.userId;

      if (userId == null || state.posts.isEmpty) return;

      // Only refresh posts that are likely visible
      final visibleStartIndex = 0;
      // Estimate how many items might be visible (typical screen shows 3-5 posts)
      final visibleEndIndex = math.min(5, state.posts.length - 1);

      // Only update those posts that are likely visible
      for (int i = visibleStartIndex; i <= visibleEndIndex; i++) {
        if (i < state.posts.length) {
          final post = state.posts[i];
          ref
              .read(postInteractionsWithPrivacyProvider(
                      PostParams(id: post.id, isAlt: post.isAlt))
                  .notifier)
              .initializeState(userId);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize feed on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Clear any current herd ID
      ref.read(currentHerdIdProvider.notifier).state = null;

      // Your existing feed initialization code
      final currentUser = ref.read(authProvider);
      ref.read(altFeedControllerProvider.notifier).loadInitialPosts(
            overrideUserId: currentUser?.uid,
          );
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener for scroll events to trigger pagination
  void _scrollListener() {
    // Get the current state
    final state = ref.read(altFeedControllerProvider);

    // If already loading or no more posts, do nothing
    if (state.isLoading || !state.hasMorePosts) return;

    // Check if we've scrolled near the bottom (reaching 2nd to last post)
    final triggerFetchMoreSize = 0.8;
    final reachedTriggerPosition = _scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent * triggerFetchMoreSize);

    if (reachedTriggerPosition) {
      // Load more posts
      ref.read(altFeedControllerProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final altFeedState = ref.watch(altFeedControllerProvider);
    final showHerdPosts =
        ref.watch(altFeedControllerProvider.notifier).showHerdPosts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alt Feed'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(altFeedControllerProvider.notifier).refreshFeed();
            },
          ),
          // Optional highlighted posts button
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () => _showHighlightedPosts(context),
          ),

          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onOpened: null,
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: showHerdPosts
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Show Herd Posts'),
                  ],
                ),
                onTap: () {
                  final controller =
                      ref.read(altFeedControllerProvider.notifier);
                  controller.toggleHerdPostsFilter(!showHerdPosts);
                },
              ),
            ],
          ),
        ],
      ),
      // Use PostListWidget instead of direct ListView.builder
      body: altFeedState.error != null
          ? _buildErrorWidget(altFeedState.error!, () {
              ref.read(altFeedControllerProvider.notifier).refreshFeed();
            })
          : altFeedState.posts.isEmpty && !altFeedState.isLoading
              ? null
              : PostListWidget(
                  posts: altFeedState.posts,
                  isLoading: altFeedState.isLoading,
                  hasError: false,
                  hasMorePosts: altFeedState.hasMorePosts,
                  scrollController: _scrollController,
                  onRefresh: () => ref
                      .read(altFeedControllerProvider.notifier)
                      .refreshFeed(),
                  onLoadMore: () => ref
                      .read(altFeedControllerProvider.notifier)
                      .loadMorePosts(),
                  type: PostListType.feed,
                  emptyMessage: 'No alt posts yet',
                  emptyActionLabel: 'Create a alt post',
                  onEmptyAction: () {
                    // Navigate to create post screen with isAlt=true
                  },
                ),
    );
  }

  /// Build the main body of the feed based on state
  Widget _buildBody(AltFeedState state) {
    // Show error if any
    if (state.error != null) {
      return _buildErrorWidget(state.error!, () {
        ref.read(altFeedControllerProvider.notifier).refreshFeed();
      });
    }

    // Show loading indicator if loading initially with no posts
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show empty state if no posts and not loading
    // if (state.posts.isEmpty && !state.isLoading) {
    //   return _buildEmptyFeed();
    // }

    // Show posts with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(altFeedControllerProvider.notifier).refreshFeed(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.posts.length + (state.isLoading ? 2 : 1),
        itemBuilder: (context, index) {
          print("DEBUG UI: Building item at index $index");
          // Bottom loading indicator (before the padding)
          if (index == state.posts.length && state.isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Bottom padding at the very end
          if (index == state.posts.length ||
              (index == state.posts.length + 1 && state.isLoading)) {
            return const BottomNavPadding();
          }

          // Regular post
          return PostWidget(post: state.posts[index], isCompact: false);
        },
      ),
    );
  }

  /// Empty feed state widget
  // Widget _buildEmptyFeed() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           Icons.lock,
  //           size: 64,
  //           color: Colors.blue.withOpacity(0.5),
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'No alt posts yet',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Be the first to create a alt post!',
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 24),
  //         ElevatedButton.icon(
  //           icon: const Icon(Icons.edit),
  //           label: const Text('Create a alt post'),
  //           onPressed: () {
  //             // Navigate to create post screen with isAlt=true
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.blue,
  //             foregroundColor: Colors.white,
  //           ),
  //         ),
  //         const BottomNavPadding(),
  //       ],
  //     ),
  //   );
  // }

  /// Error widget with retry button
  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load alt feed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
            const BottomNavPadding(),
          ],
        ),
      ),
    );
  }

  /// Show highlighted posts modal
  void _showHighlightedPosts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text(
                        "Highlighted Posts",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final highlightedPosts =
                          ref.watch(highlightedAltPostsProvider);

                      return highlightedPosts.when(
                        data: (posts) {
                          if (posts.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_border,
                                      size: 64,
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "No highlighted posts",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Popular alt posts will appear here",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: posts.length + 1, // +1 for padding
                            itemBuilder: (context, index) {
                              if (index == posts.length) {
                                return const BottomNavPadding(height: 100);
                              }
                              return PostWidget(post: posts[index]);
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child:
                              Text("Error loading highlighted posts: $error"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
