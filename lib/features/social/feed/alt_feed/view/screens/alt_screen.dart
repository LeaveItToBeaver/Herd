import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_data_providers.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

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
    // Remove this to prevent rebuilds when keyboard appears
    // _refreshVisiblePostInteractions();
  }

  void _refreshVisiblePostInteractions() {
    if (!mounted) return;

    Future.microtask(() {
      final controller = ref.read(altFeedControllerProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync.userId;

      if (userId == null || controller.state.posts.isEmpty) return;

      // Initialize all posts, not just estimated visible ones
      for (int i = 0; i < controller.state.posts.length; i++) {
        final post = controller.state.posts[i];
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
      await ref.read(altFeedControllerProvider).loadInitialPosts(
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
    final controller = ref.watch(altFeedControllerProvider);
    final altFeedState = controller.state;
    final showHerdPosts = controller.showHerdPosts;
    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);

    return PopScope(
      canPop: false, // Disable swipe to close
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Alt Feed'),
          actions: [
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(altFeedControllerProvider).refreshFeed();
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
                    final controller = ref.read(altFeedControllerProvider);
                    controller.toggleHerdPostsFilter(!showHerdPosts);
                  },
                ),
              ],
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        // Main body with sort widget and feed content
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Sort widget takes full width - stays above bubbles
            FeedSortWidget(
              currentSort: altFeedState.sortType,
              onSortChanged: (newSortType) {
                ref.read(altFeedControllerProvider).changeSortType(newSortType);
              },
              isLoading: altFeedState.isLoading,
            ),

            // Single Expanded widget with Stack
            Expanded(
              child: Stack(
                children: [
                  // Wrap the content in a RepaintBoundary to isolate repaints
                  RepaintBoundary(
                    child: _FeedContentWrapper(
                      scrollController: _scrollController,
                      altFeedState: altFeedState,
                      buildLoadingWidget: _buildLoadingWidget,
                      buildErrorWidget: _buildErrorWidget,
                    ),
                  ),

                  // Isolate the side bubbles in a separate Consumer
                  Consumer(
                    builder: (context, ref, child) {
                      final isChatEnabled =
                          ref.watch(chatBubblesEnabledProvider);

                      if (!isChatEnabled) return const SizedBox.shrink();

                      return Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeBottom: true,
                          child: Builder(
                            builder: (context) {
                              final originalMediaQuery = MediaQuery.of(context);
                              final keyboardFreeMediaQuery =
                                  originalMediaQuery.copyWith(
                                size: Size(
                                  originalMediaQuery.size.width,
                                  originalMediaQuery.size.height +
                                      originalMediaQuery.viewInsets.bottom,
                                ),
                                viewInsets: EdgeInsets.zero,
                                viewPadding:
                                    originalMediaQuery.viewPadding.copyWith(
                                  bottom: originalMediaQuery.viewPadding.bottom,
                                ),
                              );

                              return MediaQuery(
                                data: keyboardFreeMediaQuery,
                                child: SafeArea(
                                  top: false,
                                  left: false,
                                  right: false,
                                  bottom: false,
                                  child: SideBubblesOverlay(
                                    showProfileBtn: false,
                                    showSearchBtn: false,
                                    showNotificationsBtn: false,
                                    showChatToggle: false,
                                    showHerdBubbles: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // Close Scaffold
    ); // Close PopScope
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

class _FeedContentWrapper extends ConsumerWidget {
  final ScrollController scrollController;
  final AltFeedState altFeedState;
  final Widget Function() buildLoadingWidget;
  final Widget Function(
          BuildContext context, Object error, VoidCallback onRetry)
      buildErrorWidget;

  const _FeedContentWrapper({
    required this.scrollController,
    required this.altFeedState,
    required this.buildLoadingWidget,
    required this.buildErrorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch chat enabled state through select to minimize rebuilds
    final hasChat = ref.watch(
      chatBubblesEnabledProvider.select((enabled) => enabled),
    );
    final isOverlayActive = ref.watch(activeOverlayTypeProvider) != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(right: hasChat ? 60 : 0),
      child: RepaintBoundary(
        child: altFeedState.isLoading && altFeedState.posts.isEmpty
            ? buildLoadingWidget()
            : altFeedState.error != null
                ? buildErrorWidget(context, altFeedState.error!, () {
                    ref.read(altFeedControllerProvider).refreshFeed();
                  })
                : PostListWidget(
                    scrollController: scrollController,
                    posts: altFeedState.posts,
                    isLoading: altFeedState.isLoading,
                    hasError: altFeedState.error != null,
                    errorMessage: altFeedState.error?.toString(),
                    hasMorePosts: altFeedState.hasMorePosts,
                    onRefresh: () =>
                        ref.read(altFeedControllerProvider).refreshFeed(),
                    onLoadMore: () =>
                        ref.read(altFeedControllerProvider).loadMorePosts(),
                    type: PostListType.feed,
                    emptyMessage: 'No alt posts yet',
                    emptyActionLabel: 'Create an alt post',
                    onEmptyAction: () {
                      context.pushNamed(
                        'create',
                        queryParameters: {'isAlt': 'true'},
                      );
                    },
                    isRefreshing: altFeedState.isRefreshing,
                  ),
      ),
    );
  }
}
