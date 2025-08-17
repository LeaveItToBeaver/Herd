import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';

class HerdOverlayWidget extends ConsumerStatefulWidget {
  final String herdId;
  final VoidCallback onClose;

  const HerdOverlayWidget({
    super.key,
    required this.herdId,
    required this.onClose,
  });

  @override
  ConsumerState<HerdOverlayWidget> createState() => _HerdOverlayWidgetState();
}

class _HerdOverlayWidgetState extends ConsumerState<HerdOverlayWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    // Initialize the herd feed
    Future.microtask(() {
      if (mounted) {
        ref.read(currentHerdIdProvider.notifier).state = widget.herdId;
        ref
            .read(herdFeedControllerProvider(widget.herdId).notifier)
            .loadInitialPosts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final herdAsync = ref.watch(herdProvider(widget.herdId));
    final isMemberAsync = ref.watch(isHerdMemberProvider(widget.herdId));
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Get theme colors
    final customization = ref.watch(uiCustomizationProvider).value;
    final appTheme = customization?.appTheme;
    final painterColor =
        appTheme?.getSurfaceColor() ?? Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Swipe down to close
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          widget.onClose();
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: statusBarHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: painterColor,
            width: 2.0,
          ),
        ),
        child: Column(
          children: [
            // Swipe indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _buildHeader(herdAsync, isMemberAsync),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Members'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: herdAsync.when(
                data: (herd) => herd != null
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPostsTab(herd),
                          _buildAboutTab(herd),
                          _buildMembersTab(herd),
                        ],
                      )
                    : const Center(child: Text('Herd not found')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text('Failed to load herd: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    AsyncValue<HerdModel?> herdAsync,
    AsyncValue<bool> isMemberAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: herdAsync.when(
        data: (herd) {
          if (herd == null) return const SizedBox.shrink();

          final isMember = isMemberAsync.value ?? false;

          return Row(
            children: [
              // Herd Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: herd.profileImageURL != null
                    ? NetworkImage(herd.profileImageURL!)
                    : null,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                child: herd.profileImageURL == null
                    ? const Icon(Icons.groups, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),

              // Herd Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      herd.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${herd.memberCount} members',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Join/Leave Button
              OutlinedButton(
                onPressed: isMemberAsync.isLoading
                    ? null
                    : () async {
                        final repo = ref.read(herdRepositoryProvider);
                        final uid = ref.read(authProvider)!.uid;

                        if (isMember) {
                          await repo.leaveHerd(widget.herdId, uid);
                        } else {
                          await repo.joinHerd(widget.herdId, uid);
                        }

                        // Invalidate relevant providers
                        ref.invalidate(isHerdMemberProvider(widget.herdId));
                        ref.invalidate(herdMembersProvider(widget.herdId));
                        ref.invalidate(herdProvider(widget.herdId));
                        ref.invalidate(profileUserHerdsProvider(uid));
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isMember ? Colors.red : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: isMemberAsync.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isMember ? 'Leave' : 'Join'),
              ),

              // Close Button
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          );
        },
        loading: () => const SizedBox(height: 60),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPostsTab(HerdModel herd) {
    final herdFeedState = ref.watch(herdFeedControllerProvider(widget.herdId));

    if (herdFeedState.isLoading && herdFeedState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (herdFeedState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text('No posts yet'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to create post with herd context
                context.pushNamed('create', queryParameters: {
                  'herdId': widget.herdId,
                  'isAlt': 'true',
                });
                widget.onClose();
              },
              child: const Text('Create first post'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(herdFeedControllerProvider(widget.herdId).notifier)
          .refreshFeed(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            herdFeedState.posts.length + (herdFeedState.hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == herdFeedState.posts.length) {
            // Load more trigger
            ref
                .read(herdFeedControllerProvider(widget.herdId).notifier)
                .loadMorePosts();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return PostWidget(
            post: herdFeedState.posts[index],
            isCompact: true, // Use compact mode for overlay
          );
        },
      ),
    );
  }

  Widget _buildAboutTab(HerdModel herd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (herd.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(herd.description),
            const SizedBox(height: 16),
          ],

          if (herd.rules.isNotEmpty) ...[
            const Text(
              'Rules',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(herd.rules),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (herd.faq.isNotEmpty) ...[
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(herd.faq),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // View Full Herd Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                context
                    .pushNamed('herd', pathParameters: {'id': widget.herdId});
                widget.onClose();
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('View Full Herd'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(HerdModel herd) {
    return ref.watch(herdMembersProvider(widget.herdId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading members: $err')),
          data: (memberIds) {
            final uniqueIds = memberIds.toSet().toList();

            if (uniqueIds.isEmpty) {
              return const Center(child: Text('No members yet'));
            }

            return ListView.builder(
              itemCount: uniqueIds.length,
              itemBuilder: (context, index) {
                final memberId = uniqueIds[index];

                return FutureBuilder(
                  future:
                      ref.read(userRepositoryProvider).getUserById(memberId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        leading: CircleAvatar(),
                        title: Text('Loading...'),
                      );
                    }

                    final user = snapshot.data!;
                    final isModerator = herd.moderatorIds.contains(user.id);
                    final isCreator = herd.creatorId == user.id;

                    return ListTile(
                      leading: UserProfileImage(
                        radius: 20,
                        profileImageUrl: user.altProfileImageURL,
                      ),
                      title: Text(user.username),
                      subtitle: isCreator
                          ? const Text('Creator')
                          : isModerator
                              ? const Text('Moderator')
                              : null,
                      trailing: isCreator
                          ? const Icon(Icons.star, color: Colors.amber)
                          : isModerator
                              ? const Icon(Icons.shield, color: Colors.blue)
                              : null,
                      onTap: () {
                        context.pushNamed(
                          'altProfile',
                          pathParameters: {'id': user.id},
                        );
                        widget.onClose();
                      },
                    );
                  },
                );
              },
            );
          },
        );
  }
}
