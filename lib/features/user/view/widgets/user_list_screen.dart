import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

import '../../data/repositories/user_repository.dart';
import '../screens/public_profile_screen.dart';

class UserListScreen extends ConsumerWidget {
  final String userId;
  final String listType; // 'followers' or 'following'
  final String title;

  const UserListScreen({
    Key? key,
    required this.userId,
    required this.listType,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepository = ref.watch(userRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: listType == 'followers'
            ? userRepository.getFollowers(userId)
            : userRepository.getFollowing(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading users: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                listType == 'followers'
                    ? 'No followers yet'
                    : 'Not following anyone yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(user: user);
            },
          );
        },
      ),
    );
  }
}

// User list tile component to display each user
class UserListTile extends StatelessWidget {
  final UserModel user;

  const UserListTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserProfileImage(
        radius: 25.0,
        profileImageUrl: user.profileImageURL,
      ),
      title: Text(
        '${user.firstName} ${user.lastName}'.trim(),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        '@${user.username}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Navigate to the user's profile
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PublicProfileScreen(userId: user.id),
          ),
        );
      },
    );
  }
}
