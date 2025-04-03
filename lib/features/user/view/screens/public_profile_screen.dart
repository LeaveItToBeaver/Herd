import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/view/providers/profile_controller_provider.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../providers/state/profile_state.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollViewController = ScrollController();

    // Load user profile data with public view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        ref.read(profileControllerProvider.notifier).loadProfile(
          widget.userId,
          isAltView: false, // Force public view
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => errorWidget(error, stack),
        data: (profile) {
          if (profile.user == null) {
            return const Center(child: Text('User not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(widget.userId, isAltView: false);
            },
            child: NestedScrollView(
              controller: _scrollViewController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  snap: false,
                  floating: true,
                  expandedHeight: 150.0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  flexibleSpace: Stack(
                    children: <Widget>[
                      Positioned.fill(
                          child: UserCoverImage(
                            isSelected: false,
                            coverImageUrl: profile.user?.coverImageURL,
                          )
                      )
                    ],
                  ),
                  actions: [
                    if (profile.isCurrentUser) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Navigate to edit profile screen with isPublic = true
                          context.push('/editProfile', extra: {
                            'user': profile.user!,
                            'isPublic': true,
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
                                  profileImageUrl: profile.user?.profileImageURL,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${profile.user?.firstName ?? ''} ${profile.user?.lastName ?? ''}'.trim(),
                                        style: Theme.of(context).textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (profile.user?.bio != null && profile.user!.bio!.isNotEmpty)
                              Text(
                                profile.user!.bio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('Posts', profile.posts.length.toString()),
                                _buildStatColumn('Followers', profile.user?.followers?.toString() ?? '0'),
                                _buildStatColumn('Following', profile.user?.following?.toString() ?? '0'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!profile.isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ref.read(profileControllerProvider.notifier)
                                        .toggleFollow(profile.isFollowing);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: profile.isFollowing
                                        ? Theme.of(context).colorScheme.surfaceVariant
                                        : Theme.of(context).colorScheme.primary,
                                    foregroundColor: profile.isFollowing
                                        ? Theme.of(context).colorScheme.onSurfaceVariant
                                        : Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: Text(profile.isFollowing ? 'Unfollow' : 'Follow'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Public posts tab - only showing public posts
                  PostListWidget(
                    posts: profile.posts.where((post) => !post.isAlt).toList(),
                    userId: profile.user?.id ?? (throw Exception("User ID is null")),
                  ),
                  // About tab - show public profile info
                  _buildAboutSection(profile),
                ],
              ),
            ),
          );
        }
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
                  _buildInfoRow('Name', '${profile.user?.firstName ?? ''} ${profile.user?.lastName ?? ''}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Username', '@${profile.user?.username ?? ''}'),
                  const SizedBox(height: 8),
                  if (profile.user?.bio != null && profile.user!.bio!.isNotEmpty) ...[
                    _buildInfoRow('Bio', profile.user!.bio!),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow('Followers', '${profile.user?.followers ?? 0}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Following', '${profile.user?.following ?? 0}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Joined', profile.user?.createdAt != null ?
                  '${profile.user!.createdAt!.day}/${profile.user!.createdAt!.month}/${profile.user!.createdAt!.year}' :
                  'Unknown'),
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
              ref.read(profileControllerProvider.notifier).loadProfile(widget.userId, isAltView: false);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}