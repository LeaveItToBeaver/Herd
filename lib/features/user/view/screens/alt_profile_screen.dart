import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/view/providers/profile_controller_provider.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../providers/state/profile_state.dart';
import '../widgets/alt_connection_request_button.dart';

class AltProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const AltProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<AltProfileScreen> createState() => _AltProfileScreenState();
}

class _AltProfileScreenState extends ConsumerState<AltProfileScreen>
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
          isAltView: true, // Force alt view
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
          // AND they don't have a alt profile set up yet
          if (profile.isCurrentUser && !profile.hasAltProfile) {
            return _buildCreateAltProfileView(profile);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(widget.userId, isAltView: true);
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
                            coverImageUrl: profile.user?.altCoverImageURL ?? profile.user?.coverImageURL,
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
                                  profileImageUrl: profile.user?.altProfileImageURL ?? profile.user?.profileImageURL,
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
                            if (profile.user?.altBio != null && profile.user!.altBio!.isNotEmpty)
                              Text(
                                profile.user!.altBio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('Alt Posts', profile.posts.where((post) => post.isAlt).length.toString()),
                                _buildStatColumn('Connections', profile.user?.friends?.toString() ?? '0'),
                                _buildStatColumn('Groups', '0'), // Assuming groups field is not yet implemented
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (!profile.isCurrentUser)
                              SizedBox(
                                width: double.infinity,
                                child: AltConnectionButton(targetUserId: profile.user!.id),
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
                      Tab(text: 'Alt Posts'),
                      Tab(text: 'Groups'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Alt posts tab - filter only alt posts
                  PostListWidget(
                    posts: profile.posts.where((post) => post.isAlt).toList(),
                    userId: profile.user?.id ?? (throw Exception("User ID is null")),
                  ),
                  // Groups tab - show user's groups
                  _buildGroupsSection(profile),
                  // About tab - show alt profile info
                  _buildAboutSection(profile),
                ],
              ),
            ),
          );
        }
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildGroupsSection(ProfileState profile) {
    // Placeholder for groups section
    return Consumer(
      builder: (context, ref, child) {
        final userHerdsAsyncValue = ref.watch(userHerdsProvider);

        return userHerdsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (herds) {
            if (herds.isEmpty) {
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
                    const Text(
                      'This user hasn\'t joined any herds yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                    if (profile.isCurrentUser) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed('createHerd');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create a Herd'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: herds.length,
              itemBuilder: (context, index) {
                final herd = herds[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: herd.profileImageURL != null
                        ? NetworkImage(herd.profileImageURL!)
                        : null,
                    child: herd.profileImageURL == null
                        ? const Icon(Icons.group)
                        : null,
                  ),
                  title: Text('h/${herd.name}'),
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
          },
        );
      },
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
                    if (profile.user?.altBio != null && profile.user!.altBio!.isNotEmpty) ...[
                      _buildInfoRow('Bio', profile.user!.altBio!),
                      const SizedBox(height: 8),
                    ],
                    _buildInfoRow('Friends', '${profile.user?.friends ?? 0}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Alt Posts', '${profile.posts.where((post) => post.isAlt).length}'),
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
                        'Show Public Profile in Alt Feed',
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
              ref.read(profileControllerProvider.notifier).loadProfile(widget.userId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}