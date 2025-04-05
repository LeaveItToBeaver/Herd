import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/widgets/post_widget.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';


import '../../../../navigation/view/widgets/BottomNavPadding.dart';
import '../../../providers/unified_feed_provider.dart';

class PublicFeedScreen extends ConsumerWidget {
  const PublicFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        itemCount: publicFeedState.posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == publicFeedState.posts.length) {
                            return const BottomNavPadding();
                          }
                          return PostWidget(post: publicFeedState.posts[index]);
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
            Icons.public,
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
                      final trendingPosts = ref.watch(trendingPublicPostsProvider);

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
