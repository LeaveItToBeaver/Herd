import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/social/mentions/view/providers/mentions_provider.dart';

class MentionsBadge extends ConsumerWidget {
  final Color? iconColor;
  final double iconSize;

  const MentionsBadge({
    super.key,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadMentionCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.alternate_email,
            color: iconColor,
            size: iconSize,
          ),
          onPressed: () {
            context.push('/mentions');
          },
        ),
        unreadCountAsync.when(
          data: (count) {
            if (count == 0) return const SizedBox.shrink();

            return Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// Example usage in AppBar:
class ExampleAppBarWithMentions extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const ExampleAppBarWithMentions({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: const [
        MentionsBadge(),
        // Other actions...
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Example usage in BottomNavigationBar:
class ExampleBottomNavWithMentions extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ExampleBottomNavWithMentions({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadMentionCountProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: unreadCountAsync.when(
            data: (count) => count > 0
                ? Badge(
                    label: Text(count > 99 ? '99+' : count.toString()),
                    child: const Icon(Icons.alternate_email),
                  )
                : const Icon(Icons.alternate_email),
            loading: () => const Icon(Icons.alternate_email),
            error: (_, __) => const Icon(Icons.alternate_email),
          ),
          label: 'Mentions',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
