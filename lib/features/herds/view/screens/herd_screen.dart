import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../../user/view/widgets/cover_image_blur_effect.dart';
import '../../data/models/herd_model.dart';
import '../widgets/herd_stats_widget.dart';
import '../widgets/posts_tab_herd_view.dart'; // Import the new widget

class HerdScreen extends ConsumerStatefulWidget {
  final String herdId;

  const HerdScreen({super.key, required this.herdId});

  @override
  ConsumerState<HerdScreen> createState() => _HerdScreenState();
}

class _HerdScreenState extends ConsumerState<HerdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color _dominantColor = Colors.transparent;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    // Use a small delay to ensure widget is fully mounted before setting state
    Future.microtask(() {
      if (mounted) {
        ref.read(currentHerdIdProvider.notifier).state = widget.herdId;
        // Initialize the feed controller here
        ref
            .read(herdFeedControllerProvider(widget.herdId).notifier)
            .loadInitialPosts();
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
    final double luminance = color.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  // Navigate to edit herd screen
  void _navigateToEditHerd(HerdModel herd) {
    context.pushNamed('editHerd', extra: herd);
  }

  @override
  Widget build(BuildContext context) {
    final memberAv = ref.watch(isHerdMemberProvider(widget.herdId));
    final herdAsyncValue = ref.watch(herdProvider(widget.herdId));
    //final isCurrentUserMember = ref.watch(isHerdMemberProvider(widget.herdId));
    final isCurrentUserModerator =
        ref.watch(isHerdModeratorProvider(widget.herdId));
    final herdFeedState = ref.watch(herdFeedControllerProvider(widget.herdId));
    final isMember = memberAv.maybeWhen(data: (m) => m, orElse: () => false);

    return Scaffold(
      body: herdAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (herd) {
          if (herd == null) {
            return const Center(child: Text('Herd not found'));
          }

          return NestedScrollView(
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
                      coverImageUrl: herd.coverImageURL,
                      dominantColor: _dominantColor,
                      scrollController: _scrollController,
                    ),
                  ),
                  actions: [
                    // Add edit button if user is moderator
                    isCurrentUserModerator.when(
                      loading: () => Container(),
                      error: (_, __) => Container(),
                      data: (isModerator) => isModerator
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToEditHerd(herd),
                              tooltip: 'Edit Herd',
                            )
                          : Container(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Show herd options
                      },
                    ),
                  ],
                ),

                // Herd header information
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
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: herd.profileImageURL != null
                                      ? NetworkImage(herd.profileImageURL!)
                                      : null,
                                  child: herd.profileImageURL == null
                                      ? const Icon(Icons.group, size: 30)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        herd.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${herd.memberCount} members',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  // disable while loading
                                  onPressed: memberAv.isLoading
                                      ? null
                                      : () async {
                                          final repo =
                                              ref.read(herdRepositoryProvider);
                                          final uid =
                                              ref.read(authProvider)!.uid;
                                          if (isMember) {
                                            await repo.leaveHerd(
                                                widget.herdId, uid);
                                            // Invalidate for the current user
                                            ref.invalidate(
                                                profileUserHerdsProvider(uid));
                                            ref.invalidate(
                                                userHerdCountProvider(uid));
                                          } else {
                                            await repo.joinHerd(
                                                widget.herdId, uid);
                                            // Invalidate for the current user
                                            ref.invalidate(
                                                profileUserHerdsProvider(uid));
                                            ref.invalidate(
                                                userHerdCountProvider(uid));
                                          }

                                          // Also invalidate for the herd creator if different
                                          if (herd.creatorId != uid) {
                                            ref.invalidate(
                                                profileUserHerdsProvider(
                                                    herd.creatorId));
                                            ref.invalidate(
                                                userHerdCountProvider(
                                                    herd.creatorId));
                                          }

                                          // Existing invalidations
                                          ref.invalidate(isHerdMemberProvider(
                                              widget.herdId));
                                          ref.invalidate(herdMembersProvider(
                                              widget.herdId));
                                          ref.invalidate(
                                              herdProvider(widget.herdId));
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMember
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                    foregroundColor: isMember
                                        ? Colors.red
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                  ),
                                  child: memberAv.isLoading
                                      // show a little spinner if you really want to indicate “loading…”
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Text(isMember ? 'Leave' : 'Join'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (herd.description.isNotEmpty)
                              Text(herd.description),
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
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'About'),
                        Tab(text: 'Members'),
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
                // Posts tab - Using our new custom widget
                PostsTabHerdView(
                  posts: herdFeedState.posts,
                  herdFeedState: herdFeedState,
                  herdId: widget.herdId,
                ),

                // About tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HerdStats widget
                      isCurrentUserModerator.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => Container(),
                        data: (isModerator) => HerdStats(
                          herd: herd,
                          isCreatorOrMod: isModerator,
                          onEditPressed: isModerator
                              ? () => _navigateToEditHerd(herd)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (herd.rules.isNotEmpty) ...[
                        const Text(
                          'Rules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(herd.rules),
                          ),
                        ),
                      ],

                      if (herd.faq.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'FAQ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(herd.faq),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Members tab
                ref.watch(herdMembersProvider(widget.herdId)).when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, st) =>
                          Center(child: Text('Error loading members: $err')),
                      data: (memberIds) {
                        // remove any accidental duplicates:
                        final uniqueIds = memberIds.toSet().toList();

                        if (uniqueIds.isEmpty) {
                          return const Center(child: Text('No members yet'));
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: uniqueIds.length,
                          itemBuilder: (context, idx) {
                            final memberId = uniqueIds[idx];
                            return FutureBuilder(
                              // you can keep your existing getUserById FutureBuilder here
                              future: ref
                                  .read(userRepositoryProvider)
                                  .getUserById(memberId),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const ListTile(
                                    leading: CircleAvatar(),
                                    title: Text('Loading…'),
                                  );
                                }
                                final user = snap.data!;
                                return ListTile(
                                  leading: UserProfileImage(
                                    radius: 20,
                                    profileImageUrl: user.altProfileImageURL,
                                  ),
                                  title: Text(user.username ?? 'User'),
                                  subtitle: herd.moderatorIds.contains(user.id)
                                      ? const Text('Moderator')
                                      : null,
                                  onTap: () => context.pushNamed(
                                    'altProfile',
                                    pathParameters: {'id': user.id},
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
              ],
            ),
          );
        },
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
