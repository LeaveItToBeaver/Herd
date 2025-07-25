import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/side_bubble_overlay_widget.dart';

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
    if (!mounted) return;

    Future.microtask(() {
      final state = ref.read(altFeedControllerProvider);
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

    // Initialize feed on first load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      ref.read(currentHerdIdProvider.notifier).state = null;

      final currentUser = ref.read(authProvider);
      await ref.read(altFeedControllerProvider.notifier).loadInitialPosts(
            overrideUserId: currentUser?.uid,
          );

      // Refresh interactions after posts are loaded
      _refreshVisiblePostInteractions();
    });
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
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
      // Main body with sort widget and feed content
      body: Stack(
        children: [
          // Main content shifted to accommodate bubbles
          Positioned(
            left: 0,
            top: 0,
            right: 70, // Space for bubbles
            bottom: 0,
            child: Column(
              children: [
                // Sort widget at the top
                FeedSortWidget(
                  currentSort: altFeedState.sortType,
                  onSortChanged: (newSortType) {
                    ref
                        .read(altFeedControllerProvider.notifier)
                        .changeSortType(newSortType);
                  },
                  isLoading: altFeedState.isLoading,
                ),
                // Main feed content
                Expanded(
                  child: altFeedState.isLoading && altFeedState.posts.isEmpty
                      ? _buildLoadingWidget()
                      : altFeedState.error != null
                          ? _buildErrorWidget(context, altFeedState.error!, () {
                              ref
                                  .read(altFeedControllerProvider.notifier)
                                  .refreshFeed();
                            })
                          : PostListWidget(
                              scrollController: _scrollController,
                              posts: altFeedState.posts,
                              isLoading: altFeedState.isLoading,
                              hasError: altFeedState.error != null,
                              errorMessage: altFeedState.error?.toString(),
                              hasMorePosts: altFeedState.hasMorePosts,
                              onRefresh: () => ref
                                  .read(altFeedControllerProvider.notifier)
                                  .refreshFeed(),
                              onLoadMore: () => ref
                                  .read(altFeedControllerProvider.notifier)
                                  .loadMorePosts(),
                              type: PostListType.feed,
                              emptyMessage: 'No alt posts yet',
                              emptyActionLabel: 'Create an alt post',
                              onEmptyAction: () {
                                // Navigate to create post screen with isAlt=true context.pushNamed
                                context.pushNamed(
                                  'create',
                                  queryParameters: {'isAlt': 'true'},
                                );
                              },
                              isRefreshing: altFeedState.isRefreshing,
                            ),
                ),
              ],
            ),
          ),
          // Side bubbles overlay
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: SideBubblesOverlay(
                showProfileBtn: false, // Profile already in floating buttons
                showSearchBtn: false, // Search already in floating buttons
                showNotificationsBtn: false, // Not needed here
                showHerdBubbles: true, // Show herd bubbles for alt feed
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  /// Error widget with retry button
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
                                      color: Colors.blue.withValues(alpha: 0.5),
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
