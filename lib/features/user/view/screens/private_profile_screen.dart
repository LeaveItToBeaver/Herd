import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/view/providers/profile_controller_provider.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../providers/state/profile_state.dart';
import '../widgets/private_connection_request_button.dart';

class PrivateProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PrivateProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends ConsumerState<PrivateProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollViewController = ScrollController();

    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId.isNotEmpty) {
        ref.read(profileControllerProvider.notifier).loadProfile(
          widget.userId,
          isPrivateView: true, // Force private view
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

          // Check if this is the current user viewing their own profile
          // AND they don't have a private profile set up yet
          if (profile.isCurrentUser && !profile.hasPrivateProfile) {
            return _buildCreatePrivateProfileView(profile);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(widget.userId, isPrivateView: true);
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
                            coverImageUrl: profile.user?.privateCoverImageURL ?? profile.user?.coverImageURL,
                          )
                      )
                    ],
                  ),
                  actions: [
                    if (profile.isCurrentUser) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.notifications),
                        label: const Text('Notifications'),
                        onPressed: () {
                          context.pushNamed('connectionRequests');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Navigate to edit profile screen with isPublic = false
                          context.push('/editProfile', extra: {
                            'user': profile.user!,
                            'isPublic': false,
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => context.push('/settings'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () => ref.read(authProvider.notifier).signOut(),
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
                                  profileImageUrl: profile.user?.privateProfileImageURL ?? profile.user?.profileImageURL,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.user?.username ?? '',
                                        style: Theme.of(context).textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (profile.user?.privateBio != null && profile.user!.privateBio!.isNotEmpty)
                              Text(
                                profile.user!.privateBio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('Private Posts', profile.posts.where((post) => post.isPrivate).length.toString()),
                                _buildStatColumn('Connections', profile.user?.friends?.toString() ?? '0'),
                                _buildStatColumn('Groups', '0'), // Assuming groups field is not yet implemented
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!profile.isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: PrivateConnectionButton(targetUserId: profile.user!.id),
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
                      Tab(text: 'Private Posts'),
                      Tab(text: 'Groups'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Private posts tab - filter only private posts
                  PostListWidget(
                    posts: profile.posts.where((post) => post.isPrivate).toList(),
                    userId: profile.user?.id ?? (throw Exception("User ID is null")),
                  ),
                  // Groups tab - show user's groups
                  _buildGroupsSection(profile),
                  // About tab - show private profile info
                  _buildAboutSection(profile),
                ],
              ),
            ),
          );
        }
    );
  }

  // Build the view for when a user needs to create their private profile
  Widget _buildCreatePrivateProfileView(ProfileState profile) {
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
              'Welcome to Your Private Space',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your private profile allows you to connect with close friends and share content that\'s just for them.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to set up private profile
                context.push('/editProfile', extra: {
                  'user': profile.user!,
                  'isPublic': false,
                  'isInitialSetup': true,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Set Up Your Private Profile'),
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

  Widget _buildGroupsSection(ProfileState profile) {
    // Placeholder for groups section
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Groups Yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Join or create groups to connect with others',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (profile.isCurrentUser)
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create or join group screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create or Join Group'),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileState profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Private Profile',
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
                    if (profile.user?.privateBio != null && profile.user!.privateBio!.isNotEmpty) ...[
                      _buildInfoRow('Bio', profile.user!.privateBio!),
                      const SizedBox(height: 8),
                    ],
                    _buildInfoRow('Friends', '${profile.user?.friends ?? 0}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Private Posts', '${profile.posts.where((post) => post.isPrivate).length}'),
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
                      _buildSwitchRow(
                        'Show Public Profile in Private Feed',
                        true, // Default value
                            (value) {
                          // Update setting
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchRow(
                        'Allow Connection Requests',
                        true, // Default value
                            (value) {
                          // Update setting
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchRow(
                        'Show Activity Status',
                        false, // Default value
                            (value) {
                          // Update setting
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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

  Widget _buildSwitchRow(String label, bool initialValue, Function(bool) onChanged) {
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
      print('Private Profile Screen Error: $error');
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
              ref.read(profileControllerProvider.notifier).loadProfile(widget.userId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}