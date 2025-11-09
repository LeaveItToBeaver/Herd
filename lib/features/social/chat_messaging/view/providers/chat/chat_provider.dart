// Re-export generated providers from notifier files
export 'notifiers/optimistic_messages_notifier.dart';
export 'notifiers/messages_notifier.dart' show messagesProvider;
export '../message/message_provider.dart' show messageProvider;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/core/barrels/providers.dart';

part 'chat_provider.g.dart';

/// Provider for getting a specific chat by bubble ID
@riverpod
Future<ChatModel?> currentChat(Ref ref, String bubbleId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final currentUserAsync = ref.watch(currentUserProvider);
  final currentUser = currentUserAsync.when(
    data: (u) => u,
    loading: () => null,
    error: (_, __) => null,
  );
  if (currentUser == null) throw Exception('User not authenticated');
  return repo.getChatByBubbleId(bubbleId, currentUser.id);
}
