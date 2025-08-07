import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/chat_messaging_data.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/active_chat_provider.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with TickerProviderStateMixin {
  // <-- Changed from SingleTickerProviderStateMixin
  late TabController _tabController;
  late ScrollController _scrollController;
  final Color _dominantColor = Colors.transparent;
  final List<Color> _imageColors = [];
  final int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with default 2 tabs, will be updated once we know if user is current user
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();

    // Load user profile data with public view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        ref.read(profileControllerProvider.notifier).loadProfile(
              widget.userId,
              isAltView: false,
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Add this method to determine appropriate text color based on background
  Brightness _getBrightness(Color color) {
    // Calculate the color's luminance (0.0 for black, 1.0 for white)
    final double luminance = color.computeLuminance();

    // A common threshold is 0.5
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return profileState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => errorWidget(error, stack),
      data: (profile) {
        if (profile.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Initialize tab controller after we know if it's the current user
        // Only initialize if not already initialized with the correct count
        final isCurrentUser = profile.isCurrentUser;
        final requiredTabCount = isCurrentUser ? 3 : 2;
        if (_tabController.length != requiredTabCount) {
          // Dispose the old controller first
          _tabController.dispose();
          _tabController = TabController(length: requiredTabCount, vsync: this);
        }

        // Get posts filtered for the right view
        final filteredPosts =
            profile.posts.where((post) => !post.isAlt).toList();

        return Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar with cover image
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 150.0,
                  backgroundColor: _dominantColor,
                  iconTheme: IconThemeData(
                    color: _getBrightness(_dominantColor) == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  flexibleSpace: RepaintBoundary(
                    child: CoverImageBlurEffect(
                      coverImageUrl: profile.user?.coverImageURL,
                      dominantColor: _dominantColor,
                      scrollController: _scrollController,
                    ),
                  ),
                  actions: [
                    if (profile.isCurrentUser) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          // Navigate to edit profile and wait for the result
                          final result =
                              await context.push('/editProfile', extra: {
                            'user': profile.user,
                            'isPublic': true,
                          });

                          // Force refresh the profile when returning from edit screen
                          if (result == true || result != null) {
                            ref
                                .read(profileControllerProvider.notifier)
                                .loadProfile(
                                  widget.userId,
                                  isAltView: false,
                                );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => context.push('/settings'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () =>
                            ref.read(authProvider.notifier).signOut(),
                      ),
                    ],
                  ],
                ),

                // Profile card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                UserProfileImage(
                                  radius: 40.0,
                                  profileImageUrl:
                                      profile.user?.profileImageURL,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${profile.user?.firstName ?? ''} ${profile.user?.lastName ?? ''}'
                                            .trim(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (profile.user?.bio != null &&
                                profile.user!.bio!.isNotEmpty)
                              Text(
                                profile.user!.bio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(
                                    'Posts',
                                    profile.user?.totalPosts.toString() ?? '0',
                                    profile.isCurrentUser,
                                    'posts'),
                                _buildStatColumn(
                                    'Followers',
                                    profile.user?.followers.toString() ?? '0',
                                    profile.isCurrentUser,
                                    'followers'),
                                _buildStatColumn(
                                    'Following',
                                    profile.user?.following.toString() ?? '0',
                                    profile.isCurrentUser,
                                    'following'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!profile.isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                            profileControllerProvider.notifier)
                                        .toggleFollow(profile.isFollowing);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: profile.isFollowing
                                        ? Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                        : Theme.of(context).colorScheme.primary,
                                    foregroundColor: profile.isFollowing
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                  ),
                                  child: Text(profile.isFollowing
                                      ? 'Unfollow'
                                      : 'Follow'),
                                ),
                              ),
                            if (!profile.isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.message),
                                  label: const Text('Message'),
                                  onPressed: () async {
                                    final chatRepo =
                                        ref.read(chatRepositoryProvider);
                                    final currentUserId =
                                        ref.read(authProvider)?.uid;

                                    if (currentUserId != null) {
                                      final chat =
                                          await chatRepo.getOrCreateDirectChat(
                                              currentUserId: currentUserId,
                                              otherUserId: profile.user!.id);

                                      // Add the chat bubble to active chats
                                      if (chat != null) {
                                        ref
                                            .read(activeChatBubblesProvider
                                                .notifier)
                                            .addChatBubble(chat);
                                      }
                                    }
                                  },
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab Bar (as a sticky header)
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: [
                        const Tab(text: 'Posts'),
                        const Tab(text: 'About'),
                        // Only show Drafts tab for current user
                        if (isCurrentUser) const Tab(text: 'Drafts'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Posts tab with pinned posts
                _buildPostsTabWithPinnedPosts(filteredPosts, profile),
                // About tab
                SingleChildScrollView(
                  child: _buildAboutSection(profile),
                ),
                // Drafts tab - Only for current user
                if (isCurrentUser) const DraftsTabView(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTabWithPinnedPosts(
      List<PostModel> posts, ProfileState profile) {
    return PostsTabView(
      posts: posts,
      profile: profile,
      userId: widget.userId,
      isAltView: false, // This is the public profile
    );
  }

  Widget _buildStatColumn(
      String label, String count, bool isCurrentUser, String statType) {
    return GestureDetector(
      onTap: () {
        // Only navigate if it's followers or following and there are users to show
        if ((statType == 'followers' || statType == 'following') &&
            count != '0' &&
            (isCurrentUser || statType == 'followers')) {
          context.push(
            '/userList',
            extra: {
              'userId': widget.userId,
              'listType': statType,
              'title': label,
            },
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileState profile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Name',
                      '${profile.user?.firstName ?? ''} ${profile.user?.lastName ?? ''}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Username', '@${profile.user?.username ?? ''}'),
                  const SizedBox(height: 8),
                  if (profile.user?.bio != null &&
                      profile.user!.bio!.isNotEmpty) ...[
                    _buildInfoRow('Bio', profile.user!.bio!),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow('Followers', '${profile.user?.followers ?? 0}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Following', '${profile.user?.following ?? 0}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Joined',
                      profile.user?.createdAt != null
                          ? '${profile.user!.createdAt!.day}/${profile.user!.createdAt!.month}/${profile.user!.createdAt!.year}'
                          : 'Unknown'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget errorWidget(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Public Profile Screen Error: $error');
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'An error occurred: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(widget.userId, isAltView: false);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    // Ensure currentThemeProvider sets scaffoldBackgroundColor from AppThemeSettings.backgroundColor
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}
