import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/mentions/models/mention_model.dart';

// Provider for mention repository
final mentionRepositoryProvider = Provider((ref) => MentionRepository());

// Stream provider for user mentions
final userMentionsProvider = StreamProvider.autoDispose((ref) {
  final currentUser = ref.watch(authProvider);
  if (currentUser == null) {
    return Stream.value(<MentionModel>[]);
  }

  final repository = ref.watch(mentionRepositoryProvider);
  return repository.getUserMentions(currentUser.uid, includeRead: false);
});

// Provider for unread mention count
final unreadMentionCountProvider = StreamProvider.autoDispose((ref) {
  final currentUser = ref.watch(authProvider);
  if (currentUser == null) {
    return Stream.value(0);
  }

  // Get mentions stream and map to count
  final mentionsStream = ref
      .watch(mentionRepositoryProvider)
      .getUserMentions(currentUser.uid, includeRead: false);

  return mentionsStream.map((mentions) => mentions.length);
});

// Alternative: Future provider for one-time fetch
final unreadMentionCountFutureProvider =
    FutureProvider.autoDispose((ref) async {
  final currentUser = ref.watch(authProvider);
  if (currentUser == null) return 0;

  final repository = ref.watch(mentionRepositoryProvider);
  return repository.getUnreadMentionCount(currentUser.uid);
});

// Provider to mark mention as read
final markMentionAsReadProvider = Provider.autoDispose((ref) {
  final repository = ref.watch(mentionRepositoryProvider);

  return (String userId, String mentionId) async {
    await repository.markMentionAsRead(userId, mentionId);
    // Invalidate the mentions provider to refresh the list
    ref.invalidate(userMentionsProvider);
    ref.invalidate(unreadMentionCountProvider);
  };
});

// Provider to mark all mentions as read
final markAllMentionsAsReadProvider = Provider.autoDispose((ref) {
  final repository = ref.watch(mentionRepositoryProvider);

  return (String userId) async {
    await repository.markAllMentionsAsRead(userId);
    // Invalidate the mentions provider to refresh the list
    ref.invalidate(userMentionsProvider);
    ref.invalidate(unreadMentionCountProvider);
  };
});
