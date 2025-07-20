import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/community/moderation/view/screens/pinned_post_management_screen.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/content/post/view/widgets/pinned_posts/pinned_post_widget.dart';
import 'package:herdapp/features/content/post/view/widgets/post_widget.dart';
import 'package:herdapp/features/ui/navigation/view/widgets/BottomNavPadding.dart';
import '../providers/herd_providers.dart';
import '../providers/state/herd_feed_state.dart';

class PostsTabHerdView extends ConsumerWidget {
  final List<PostModel> posts;
  final HerdFeedState herdFeedState;
  final String herdId;

  const PostsTabHerdView({
    super.key,
    required this.posts,
    required this.herdFeedState,
    required this.herdId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedPostsAsync = ref.watch(herdPinnedPostsProvider(herdId));
    if (posts.isEmpty) {
      // Empty state with a scrollable list for refresh indicator
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(herdFeedControllerProvider(herdId).notifier)
              .refreshFeed();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add,
                      size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No posts yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.pushNamed('create',
                          queryParameters: {'herdId': herdId});
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // For the list state, wrap CustomScrollView with local RefreshIndicator
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Only handle pagination in the actual post list
          if (scrollInfo.depth == 0 && // This is the direct scroll view
              scrollInfo.metrics.pixels >
                  scrollInfo.metrics.maxScrollExtent * 0.8) {
            if (!herdFeedState.isLoading && herdFeedState.hasMorePosts) {
              if (kDebugMode) {
                print('Loading more posts from HERD TAB VIEW');
              }

              ref
                  .read(herdFeedControllerProvider(herdId).notifier)
                  .loadMorePosts();
            }
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(herdFeedControllerProvider(herdId).notifier)
                .refreshFeed();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              pinnedPostsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: PinnedPostsLoadingWidget(),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error loading pinned posts: $err'),
                    ),
                  ),
                ),
                data: (pinnedPosts) {
                  if (pinnedPosts.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverToBoxAdapter(
                    child: PinnedPostsWidget(
                      pinnedPosts: pinnedPosts,
                      showTitle: true,
                      emptyMessage: 'No pinned posts in this herd yet.',
                    ),
                  );
                },
              ),
              SliverList.builder(
                itemCount: posts.length + (herdFeedState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (herdFeedState.isLoading && index == posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return RepaintBoundary(
                    child: PostWidget(
                      post: posts[index],
                      isCompact: true,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: BottomNavPadding(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
