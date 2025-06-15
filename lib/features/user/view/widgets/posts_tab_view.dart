import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/post/view/providers/pinned_post_provider.dart';
import 'package:herdapp/features/post/view/widgets/pinned_posts/pinned_post_widget.dart';
import 'package:herdapp/features/user/view/providers/profile_controller_provider.dart';

import '../../../post/data/models/post_model.dart';
import '../../profile_controller.dart';
import '../providers/state/profile_state.dart';

class PostsTabView extends ConsumerWidget {
  final List<PostModel> posts;
  final ProfileState profile;
  final String userId;
  final bool
      isAltView; // Add this parameter to distinguish between alt and public

  const PostsTabView({
    super.key,
    required this.posts,
    required this.profile,
    required this.userId,
    this.isAltView = false, // Default to public view
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      // Empty state with a scrollable list for refresh indicator
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider.notifier)
              .loadProfile(userId, isAltView: isAltView);
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
                      size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No posts yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (profile.isCurrentUser) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.pushNamed('create');
                      },
                    )
                  ]
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
            if (!profile.isLoading && profile.hasMorePosts) {
              if (kDebugMode) {
                print('Loading more posts from POSTS TAB VIEW');
              }

              ref
                  .read(profileControllerProvider.notifier)
                  .loadMorePosts(userId);
            }
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(profileControllerProvider.notifier)
                .loadProfile(userId, isAltView: isAltView);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Pinned posts section
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    // Watch the appropriate pinned posts provider based on view type
                    final pinnedPostsAsync = isAltView
                        ? ref.watch(userAltPinnedPostsProvider(userId))
                        : ref.watch(userPinnedPostsProvider(userId));

                    return pinnedPostsAsync.when(
                      data: (pinnedPosts) {
                        // Filter pinned posts to match the current view
                        final filteredPinnedPosts = pinnedPosts
                            .where((post) => post.isAlt == isAltView)
                            .toList();

                        if (filteredPinnedPosts.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return PinnedPostsWidget(
                          pinnedPosts: filteredPinnedPosts,
                          showTitle: true,
                        );
                      },
                      loading: () => const PinnedPostsLoadingWidget(),
                      error: (error, stack) {
                        debugPrint('Error loading pinned posts: $error');
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),

              // Regular posts
              SliverList.builder(
                itemCount: posts.length + (profile.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (profile.isLoading && index == posts.length) {
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
