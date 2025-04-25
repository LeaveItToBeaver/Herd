import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/view/providers/profile_controller_provider.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../../herds/data/models/herd_model.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../post/data/models/post_model.dart';
import '../providers/state/profile_state.dart';
import '../widgets/cover_image_blur_effect.dart';
import '../widgets/posts_tab_view.dart';

class AltProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const AltProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<AltProfileScreen> createState() => _AltProfileScreenState();
}

class _AltProfileScreenState extends ConsumerState<AltProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final Color _dominantColor = Colors.transparent;
  final double _scrollProgress = 0.0;
  final List<Color> _imageColors = [];

  @override
  void initState() {
    super.initState();
    // Initialize with a default value (2 tabs)
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();

    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        ref.read(profileControllerProvider.notifier).loadProfile(
              widget.userId,
              isAltView: true, // Force alt view
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

  // Initialize tab controller based on user
  void _initTabController(bool isCurrentUser) {
    // 3 tabs for current user, 2 for other users
    final tabCount = isCurrentUser ? 3 : 2;

    // Create a new tab controller with the appropriate number of tabs
    _tabController = TabController(length: tabCount, vsync: this);

    // We need to notify the tab controller that it needs to update
    if (mounted) setState(() {});
  }

  // Add this method to determine appropriate text color based on background
  Brightness _getBrightness(Color color) {
    // Calculate the color's luminance (0.0 for black, 1.0 for white)
    final double luminance = color.computeLuminance();

    // A common threshold is 0.5, but you can adjust for your preference
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

        // Check if this is the current user viewing their own profile
        // AND they don't have a alt profile set up yet
        if (isCurrentUser && !profile.hasAltProfile) {
          return _buildCreateAltProfileView(profile);
        }

        // Get alt posts only
        final altPosts = profile.posts;

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
                      coverImageUrl: profile.user?.altCoverImageURL,
                      dominantColor: _dominantColor,
                      scrollController: _scrollController,
                    ),
                  ),
                  actions: [
                    if (isCurrentUser) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.notifications),
                        label: const Text('Notifications'),
                        onPressed: () {
                          context.pushNamed('connectionRequests');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          // Navigate to edit profile and wait for the result
                          final result =
                              await context.push('/editProfile', extra: {
                            'user': profile.user,
                            'isPublic': false,
                          });

                          // Force refresh the profile when returning from edit screen
                          if (result == true || result != null) {
                            ref
                                .read(profileControllerProvider.notifier)
                                .loadProfile(
                                  widget.userId,
                                  isAltView: true,
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
                              .withOpacity(0.1),
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
                                      profile.user?.altProfileImageURL ??
                                          profile.user?.profileImageURL,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.user?.username ?? '',
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
                            if (profile.user?.altBio != null &&
                                profile.user!.altBio!.isNotEmpty)
                              Text(
                                profile.user!.altBio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(
                                    'Alt Posts', altPosts.length.toString()),
                                _buildStatColumn('Connections',
                                    profile.user?.friends.toString() ?? '0'),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final herdCount = ref.watch(
                                        userHerdCountProvider(widget.userId));
                                    return _buildStatColumn(
                                      'Herds',
                                      herdCount.when(
                                        data: (count) => count.toString(),
                                        loading: () => '...',
                                        error: (_, __) => '0',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: AltConnectionButton(
                                    targetUserId: profile.user!.id),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab Bar (as a sticky header) - Dynamically show tabs based on user
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: [
                        const Tab(text: 'Alt Posts'),
                        const Tab(text: 'About'),
                        // Only show Herds tab for current user
                        if (isCurrentUser) const Tab(text: 'Herds'),
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
                // Alt posts tab - Now using a custom list to handle both empty state and list
                PostsTabView(
                  posts: altPosts,
                  profile: profile,
                  userId: widget.userId,
                ),

                // About tab
                SingleChildScrollView(
                  child: _buildAboutSection(profile),
                ),

                // Herds tab - Only for current user
                if (isCurrentUser) _buildHerdsSection(profile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab(List<PostModel> posts, ProfileState profile) {
    if (posts.isEmpty) {
      // Empty state with a fallback scrollable to enable pull-to-refresh
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider.notifier)
              .loadProfile(widget.userId, isAltView: true);
        },
        child: ListView(
          // This ensures RefreshIndicator can work even with centered content
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock,
                      size: 64, color: Colors.blue.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No alt posts yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (profile.isCurrentUser) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Alt Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.pushNamed('create',
                            queryParameters: {'isAlt': 'true'});
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
      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider.notifier)
              .loadProfile(widget.userId, isAltView: true);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList.builder(
              itemCount: posts.length + (profile.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (profile.isLoading && index == posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return PostWidget(
                  post: posts[index],
                  isCompact: true,
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      );
    }
  }

  // Build the view for when a user needs to create their alt profile
  Widget _buildCreateAltProfileView(ProfileState profile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Your Alt Space',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your alt profile allows you to connect with close friends and share content that\'s just for them.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to set up alt profile
                context.push('/editProfile', extra: {
                  'user': profile.user!,
                  'isPublic': false,
                  'isInitialSetup': true,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Set Up Your Alt Profile'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Go back to public feed
                context.go('/publicFeed');
              },
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
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
    );
  }

  Widget _buildHerdsSection(ProfileState profile) {
    return Consumer(
      builder: (context, ref, child) {
        final userHerdsAsyncValue =
            ref.watch(profileUserHerdsProvider(widget.userId));

        return userHerdsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (herds) {
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh herds data for this specific user
                      ref.refresh(profileUserHerdsProvider(widget.userId));
                    },
                    child: herds.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                alignment: Alignment.center,
                                child: _buildEmptyHerdsView(profile),
                              ),
                            ],
                          )
                        : _buildHerdsList(herds),
                  ),
                ),
                // Only show Create Herd button for current user
                if (profile.isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed('createHerd');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Herd'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                BottomNavPadding(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHerdsView(ProfileState profile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Herds',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            profile.isCurrentUser
                ? 'You haven\'t joined any herds yet'
                : 'This user hasn\'t joined any herds yet',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// New method for herds list
  Widget _buildHerdsList(List<HerdModel> herds) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Important to avoid extra padding
      itemCount: herds.length,
      itemBuilder: (context, index) {
        final herd = herds[index];

        return ListTile(
          leading: UserProfileImage(
              radius: 40.0, profileImageUrl: herd.profileImageURL),
          title: Text(herd.name),
          subtitle: Text('${herd.memberCount} members'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            context.pushNamed(
              'herd',
              pathParameters: {'id': herd.id},
            );
          },
        );
      },
    );
  }

  Widget _buildAboutSection(ProfileState profile) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alt Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Username', '@${profile.user?.username}'),
                  const SizedBox(height: 8),
                  if (profile.user?.altBio != null &&
                      profile.user!.altBio!.isNotEmpty) ...[
                    _buildInfoRow('Bio', profile.user!.altBio!),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow('Friends', '${profile.user?.friends ?? 0}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Alt Posts',
                      '${profile.posts.where((post) => post.isAlt).length}'),
                ],
              ),
            ),
          ),
          if (profile.isCurrentUser) ...[
            const SizedBox(height: 24),
            const Text(
              'Privacy Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                        "This section will include settings that you might want to toggle off or on at a moments notice. For now, just enjoy this empty space."),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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

  Widget _buildSwitchRow(
      String label, bool initialValue, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label),
        ),
        Switch(
          value: initialValue,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget errorWidget(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Alt Profile Screen Error: $error');
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
                  .loadProfile(widget.userId);
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
