import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

class PublicFeedScreen extends ConsumerStatefulWidget {
  const PublicFeedScreen({super.key});

  @override
  ConsumerState<PublicFeedScreen> createState() => _PublicFeedScreenState();
}

class _PublicFeedScreenState extends ConsumerState<PublicFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Avoid re-initializing interaction state for the same list repeatedly.
  Set<String> _initializedInteractionPostIds = {};

  bool _feedListenerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove this to prevent rebuilds when keyboard appears
    // _refreshVisiblePostInteractions();
  }

  void _refreshVisiblePostInteractions() {
    if (!mounted) return;

    Future.microtask(() {
      final controllerState = ref.read(publicFeedStateProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync.userId;

      if (userId == null || controllerState.posts.isEmpty) return;

      final nextIds = controllerState.posts.map((p) => p.id).toSet();
      if (nextIds.length == _initializedInteractionPostIds.length &&
          nextIds.containsAll(_initializedInteractionPostIds)) {
        return;
      }
      _initializedInteractionPostIds = nextIds;

      // Initialize all posts, not just estimated visible ones
      for (int i = 0; i < controllerState.posts.length; i++) {
        final post = controllerState.posts[i];
        ref
            .read(postInteractionsWithPrivacyProvider(PostParams(
                    id: post.id, isAlt: post.isAlt, herdId: post.herdId))
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
      ref.read(publicFeedStateProvider.notifier).loadInitialPosts(
            overrideUserId: currentUser?.uid,
          );
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
    if (!_feedListenerAttached) {
      _feedListenerAttached = true;

      // Initialize interaction providers whenever the post list changes.
      // This catches: initial load, refresh, and sort changes.
      ref.listen<PublicFeedState>(publicFeedStateProvider, (prev, next) {
        if (!mounted) return;

        final prevIds = (prev?.posts ?? const []).map((p) => p.id).toSet();
        final nextIds = next.posts.map((p) => p.id).toSet();
        if (prevIds.length == nextIds.length && prevIds.containsAll(nextIds)) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _refreshVisiblePostInteractions();
        });
      });
    }

    final publicFeedState = ref.watch(publicFeedStateProvider);

    return PopScope(
      canPop: false, // Disable swipe to close
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Public Feed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(publicFeedStateProvider.notifier).refreshFeed();
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
                    .read(publicFeedStateProvider.notifier)
                    .changeSortType(newSortType);
              },
              isLoading: publicFeedState.isLoading,
            ),

            // Single Expanded widget with Stack
            Expanded(
              child: Stack(
                children: [
                  // Main content - pass content to animation wrapper which handles padding
                  Consumer(
                    builder: (context, ref, child) {
                      final isChatEnabled =
                          ref.watch(chatBubblesEnabledProvider);
                      return _PaddingAnimationWrapper(
                        isChatEnabled: isChatEnabled,
                        child: _buildContentWidget(publicFeedState),
                      );
                    },
                  ),

                  // Side bubbles overlay - only show if chat is enabled
                  // Wrapped in Consumer to isolate provider watches
                  Consumer(
                    builder: (context, ref, child) {
                      final isChatEnabled =
                          ref.watch(chatBubblesEnabledProvider);
                      if (!isChatEnabled) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        right: 0,
                        top: 0,
                        bottom:
                            0, // Full height - overlay will manage its own layout
                        child: MediaQuery.removePadding(
                          context: context,
                          removeBottom: true,
                          child: Builder(
                            builder: (context) {
                              // Complete keyboard isolation - preserve original screen size and remove insets
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
                                  top: true,
                                  left: false,
                                  right: false,
                                  bottom:
                                      false, // Don't apply SafeArea to bottom since we're handling it
                                  child: SideBubblesOverlay(
                                    showProfileBtn:
                                        false, // We'll use floating buttons from shell instead
                                    showSearchBtn:
                                        false, // We'll use floating buttons from shell instead
                                    showNotificationsBtn:
                                        false, // We'll use floating buttons from shell instead
                                    showChatToggle:
                                        false, // Chat toggle handled by shell's GlobalOverlayManager
                                    showHerdBubbles:
                                        false, // Public feed doesn't show herd bubbles
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // Note: Floating buttons are now handled by the shell's GlobalOverlayManager
                  // This prevents double-rendering of buttons
                ],
              ),
            ),
          ],
        ),
      ), // Close Scaffold
    ); // Close PopScope
  }

  Widget _buildContentWidget(PublicFeedState publicFeedState) {
    return publicFeedState.isLoading && publicFeedState.posts.isEmpty
        ? _buildLoadingWidget()
        : publicFeedState.error != null
            ? _buildErrorWidget(context, publicFeedState.error!)
            : PostListWidget(
                scrollController: _scrollController,
                posts: publicFeedState.posts,
                isLoading:
                    publicFeedState.isLoading && publicFeedState.posts.isEmpty,
                hasError: publicFeedState.error != null,
                errorMessage: publicFeedState.error?.toString(),
                hasMorePosts: publicFeedState.hasMorePosts,
                onRefresh: () =>
                    ref.read(publicFeedStateProvider.notifier).refreshFeed(),
                onLoadMore: () =>
                    ref.read(publicFeedStateProvider.notifier).loadMorePosts(),
                type: PostListType.feed,
                emptyMessage: 'No posts in your public feed yet',
                emptyActionLabel: 'Find users to follow',
                onEmptyAction: () {
                  context.pushNamed('search');
                },
                isRefreshing: publicFeedState.isRefreshing,
              );
  }

  Widget _buildLoadingWidget() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
                  onPressed: () {
                    ref.read(publicFeedStateProvider.notifier).refreshFeed();
                  },
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

/// Wraps only the padding animation to prevent child rebuilds on animation frames.
/// The child is passed as a parameter to remain stable during animation.
class _PaddingAnimationWrapper extends StatelessWidget {
  final bool isChatEnabled;
  final Widget child;

  const _PaddingAnimationWrapper({
    required this.isChatEnabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(right: isChatEnabled ? 60 : 0),
      child: child,
    );
  }
}
