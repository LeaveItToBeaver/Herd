import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:herdapp/features/social/chat_messaging/data/handlers/encrypted_media_handler.dart';
import '../state/chat_pagination_state.dart';
import 'chat_pagination_notifier.dart';

final chatPaginationProvider = StateNotifierProvider.family<
    ChatPaginationNotifier, ChatPaginationState, String>((ref, chatId) {
  final repo = ref.watch(messageRepositoryProvider);
  final cache = ref.watch(messageCacheServiceProvider);
  final mediaHandler = ref.watch(encryptedMediaHandlerProvider);
  return ChatPaginationNotifier(
      chatId: chatId, repo: repo, cache: cache, mediaHandler: mediaHandler);
});
