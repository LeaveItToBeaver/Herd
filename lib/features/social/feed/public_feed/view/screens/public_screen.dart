import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/side_bubble_overlay_widget.dart';

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
    if (!mounted) return;

    Future.microtask(() {
      final state = ref.read(publicFeedControllerProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync.userId;

      if (userId == null || state.posts.isEmpty) return;

      // Initialize all posts, not just estimated visible ones
      for (int i = 0; i < state.posts.length; i++) {
        final post = state.posts[i];
        ref
            .read(postInteractionsWithPrivacyProvider(
                    PostParams(id: post.id, isAlt: post.isAlt))
                .notifier)
            .initializeState(userId);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentUser = ref.read(authProvider);
      ref.read(publicFeedControllerProvider.notifier).loadInitialPosts(
            overrideUserId: currentUser?.uid,
          );
    });
    _refreshVisiblePostInteractions();
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicFeedState = ref.watch(publicFeedControllerProvider);

    return PopScope(
      canPop: false, // Disable swipe to close
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Public Feed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(publicFeedControllerProvider.notifier).refreshFeed();
              },
            ),
            IconButton(
              icon: const Icon(Icons.trending_up),
              onPressed: () => _showTrendingPosts(context, ref),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Sort widget takes full width - stays above bubbles
            FeedSortWidget(
              currentSort: publicFeedState.sortType,
              onSortChanged: (newSortType) {
                ref
                    .read(publicFeedControllerProvider.notifier)
                    .changeSortType(newSortType);
              },
              isLoading: publicFeedState.isLoading,
            ),

            // Single Expanded widget with Stack
            Expanded(
              child: Stack(
                children: [
                  // Main content with padding for bubbles
                  Padding(
                    padding: const EdgeInsets.only(right: 70),
                    child: publicFeedState.isLoading &&
                            publicFeedState.posts.isEmpty
                        ? _buildLoadingWidget()
                        : publicFeedState.error != null
                            ? _buildErrorWidget(context, publicFeedState.error!,
                                () {
                                ref
                                    .read(publicFeedControllerProvider.notifier)
                                    .refreshFeed();
                              })
                            : PostListWidget(
                                scrollController: _scrollController,
                                posts: publicFeedState.posts,
                                isLoading: publicFeedState.isLoading &&
                                    publicFeedState.posts.isEmpty,
                                hasError: publicFeedState.error != null,
                                errorMessage: publicFeedState.error?.toString(),
                                hasMorePosts: publicFeedState.hasMorePosts,
                                onRefresh: () => ref
                                    .read(publicFeedControllerProvider.notifier)
                                    .refreshFeed(),
                                onLoadMore: () => ref
                                    .read(publicFeedControllerProvider.notifier)
                                    .loadMorePosts(),
                                type: PostListType.feed,
                                emptyMessage:
                                    'No posts in your public feed yet',
                                emptyActionLabel: 'Find users to follow',
                                onEmptyAction: () {
                                  context.pushNamed('search');
                                },
                                isRefreshing: publicFeedState.isRefreshing,
                              ),
                  ),

                  // Side bubbles overlay
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: true,
                      left: false,
                      right: false,
                      bottom: true,
                      child: SideBubblesOverlay(
                        showProfileBtn: true,
                        showSearchBtn: true,
                        showNotificationsBtn: true,
                        showHerdBubbles:
                            false, // Public feed doesn't show herd bubbles
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // Close Scaffold
    ); // Close PopScope
  }

// Add a loading widget that's scrollable
  Widget _buildLoadingWidget() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 100),
      ],
    );
  }

// Update error widget to be scrollable
  Widget _buildErrorWidget(
      BuildContext context, Object error, VoidCallback onRetry) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
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
              ],
            ),
          ),
        ),
        const BottomNavPadding(),
      ],
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
                              return PostWidget(
                                post: posts[index],
                                isCompact: false,
                              );
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
