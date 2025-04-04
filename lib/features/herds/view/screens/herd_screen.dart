// lib/features/herds/view/screens/herd_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/post/view/widgets/post_widget.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../../user/data/repositories/user_repository.dart';

class HerdScreen extends ConsumerStatefulWidget {
  final String herdId;

  const HerdScreen({super.key, required this.herdId});

  @override
  ConsumerState<HerdScreen> createState() => _HerdScreenState();
}

class _HerdScreenState extends ConsumerState<HerdScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final herdAsyncValue = ref.watch(herdProvider(widget.herdId));
    final isCurrentUserMember = ref.watch(isHerdMemberProvider(widget.herdId));
    final postsAsyncValue = ref.watch(herdPostsProvider(widget.herdId));

    return Scaffold(
      body: herdAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (herd) {
          if (herd == null) {
            return const Center(child: Text('Herd not found'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('h/${herd.name}'),
                  background: herd.coverImageURL != null
                      ? Image.network(herd.coverImageURL!, fit: BoxFit.cover)
                      : Container(color: Colors.blueGrey),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Navigate to search
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show herd options
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          isCurrentUserMember.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => Container(),
                            data: (isMember) => ElevatedButton(
                              onPressed: () {
                                if (isMember) {
                                  ref.read(herdRepositoryProvider).leaveHerd(
                                    herd.id,
                                    ref.read(authProvider)!.uid,
                                  );
                                } else {
                                  ref.read(herdRepositoryProvider).joinHerd(
                                    herd.id,
                                    ref.read(authProvider)!.uid,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMember
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                              ),
                              child: Text(isMember ? 'Leave' : 'Join'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (herd.description.isNotEmpty)
                        Text(herd.description),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'About'),
                      Tab(text: 'Members'),
                    ],
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
                pinned: true,
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Posts tab
                postsAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(child: Text('No posts yet'));
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostWidget(post: posts[index]);
                      },
                    );
                  },
                ),

                // About tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About this herd',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(herd.description),

                      if (herd.rules.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Rules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(herd.rules),
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
                        Text(herd.faq),
                      ],
                    ],
                  ),
                ),

                // Members tab
                FutureBuilder<List<String>>(
                  future: ref.read(herdRepositoryProvider).getHerdMembers(herd.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final memberIds = snapshot.data ?? [];

                    if (memberIds.isEmpty) {
                      return const Center(child: Text('No members yet'));
                    }

                    return ListView.builder(
                      itemCount: memberIds.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: ref.read(userRepositoryProvider).getUserById(memberIds[index]),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData || userSnapshot.data == null) {
                              return const ListTile(
                                leading: CircleAvatar(),
                                title: Text('Loading...'),
                              );
                            }

                            final user = userSnapshot.data!;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.profileImageURL != null
                                    ? NetworkImage(user.profileImageURL!)
                                    : null,
                              ),
                              title: Text(user.username ?? 'User'),
                              subtitle: herd.moderatorIds.contains(user.id)
                                  ? const Text('Moderator')
                                  : null,
                              onTap: () {
                                context.pushNamed(
                                  'altProfile',
                                  pathParameters: {'id': user.id},
                                );
                              },
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
      floatingActionButton: isCurrentUserMember.when(
        loading: () => null,
        error: (_, __) => null,
        data: (isMember) => isMember ? FloatingActionButton(
          onPressed: () {
            // Navigate to create post screen with herdId
            context.pushNamed('createPost', queryParameters: {'herdId': widget.herdId});
          },
          child: const Icon(Icons.add),
        ) : null,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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