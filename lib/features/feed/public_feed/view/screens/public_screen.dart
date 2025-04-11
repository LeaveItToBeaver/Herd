import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/feed/public_feed/view/providers/public_feed_provider.dart';
import 'package:herdapp/features/post/view/widgets/post_widget.dart';

import '../../../../navigation/view/widgets/BottomNavPadding.dart';

class PublicFeedScreen extends ConsumerStatefulWidget {
  const PublicFeedScreen({super.key});

  @override
  ConsumerState<PublicFeedScreen> createState() => _PublicFeedScreenState();
}

class _PublicFeedScreenState extends ConsumerState<PublicFeedScreen> {
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
      final currentUser = ref.read(currentUserProvider);
      final state = ref.read(publicFeedControllerProvider);

      if (currentUser?.id == null || state.posts.isEmpty) return;

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
              .initializeState(currentUser!.id);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentUser = ref.read(authProvider);
      // Trigger the initial fetch of posts
      ref.read(publicFeedControllerProvider.notifier).loadInitialPosts();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Get the current state
    final state = ref.read(publicFeedControllerProvider);

    // If already loading or no more posts, do nothing
    if (state.isLoading || !state.hasMorePosts) return;

    // Check if we've scrolled near the bottom (reaching 2nd to last post)
    final triggerFetchMoreSize = 0.8;
    final reachedTriggerPosition = _scrollController.position.pixels >=
        (_scrollController.position.maxScrollExtent * triggerFetchMoreSize);

    if (reachedTriggerPosition) {
      // Load more posts
      ref.read(publicFeedControllerProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicFeedState = ref.watch(publicFeedControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Feed'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(publicFeedControllerProvider.notifier).refreshFeed();
            },
          ),
          // Optional trending button
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () => _showTrendingPosts(context, ref),
          ),
        ],
      ),
      // Use PostListWidget if possible
      body: publicFeedState.isLoading && publicFeedState.posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : publicFeedState.error != null
              ? _buildErrorWidget(context, publicFeedState.error!, () {
                  ref.read(publicFeedControllerProvider.notifier).refreshFeed();
                })
              : publicFeedState.posts.isEmpty
                  ? _buildEmptyFeed(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(publicFeedControllerProvider.notifier)
                            .refreshFeed();
                      },
                      child: ListView.builder(
                        controller:
                            _scrollController, // Ensure you have this controller
                        itemCount: publicFeedState.posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == publicFeedState.posts.length) {
                            return const BottomNavPadding();
                          }
                          // Use the new PostWidget with consistent props
                          return PostWidget(
                            post: publicFeedState.posts[index],
                            isCompact: false, // Set this consistently
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyFeed(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No posts in your public feed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Follow users or join herds to see posts here',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Find users to follow'),
            onPressed: () {
              // Navigate to search screen
            },
          ),
          const BottomNavPadding(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
      BuildContext context, Object error, VoidCallback onRetry) {
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
              'Failed to load feed',
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

  void _showTrendingPosts(BuildContext context, WidgetRef ref) {
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
                        "Trending Posts",
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
                      final trendingPosts =
                          ref.watch(trendingPublicPostsProvider);

                      return trendingPosts.when(
                        data: (posts) {
                          if (posts.isEmpty) {
                            return const Center(
                              child: Text("No trending posts at the moment"),
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
                          child: Text("Error loading trending posts: $error"),
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
