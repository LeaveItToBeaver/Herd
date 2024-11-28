import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/view/providers/auth_provider.dart';
import 'package:herdapp/core/barrels/widgets.dart';

import '../providers/profile_controller_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
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
        ref.read(profileControllerProvider.notifier).loadProfile(widget.userId);
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading profile: ${error.toString()}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(profileControllerProvider.notifier)
                      .loadProfile(widget.userId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile.user == null) {
            return const Center(child: Text('User not found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(widget.userId);
            },
            child: NestedScrollView(
              controller: _scrollViewController,
              headerSliverBuilder: (context, innerBoxIsScrolled) =>
              [
                SliverAppBar(
                  pinned: true,
                  snap: false,
                  floating: true,
                  expandedHeight: 150.0,
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .surface,
                  flexibleSpace: Stack(
                    children: <Widget>[
                      Positioned.fill(child: UserCoverImage(
                        isSelected: false,
                        coverImageUrl: profile.user?.coverImageURL,
                      ))
                    ],
                  ),
                  actions: [
                    if (profile.isCurrentUser) ...[
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => context.push('/settings'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () =>
                            ref.read(authProvider.notifier)
                                .signOut(),
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
                          color: Theme
                              .of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                UserProfileImage(
                                  radius: 40.0,
                                  profileImageUrl: profile.user
                                      ?.profileImageURL,
                                ),
                                const SizedBox(width: 16),
                                ProfileStats(
                                  isCurrentUser: profile.isCurrentUser,
                                  isFollowing: profile.isFollowing,
                                  followers: profile.user?.followers ?? 0,
                                  following: profile.user?.following ?? 0,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ProfileInfo(
                              username: profile.user?.username ?? '',
                              bio: profile.user?.bio ?? '',
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
                    labelColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    unselectedLabelColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .onSurfaceVariant,
                    indicatorColor: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Comments'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  PostListWidget(
                    posts: profile.posts,
                    userId: profile.user?.id ??
                        (throw Exception("User ID is null")),
                  ),
                  const CommentListWidget(),
                  const AboutSectionWidget(),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget errorWidget(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Profile Screen Error: $error');
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
