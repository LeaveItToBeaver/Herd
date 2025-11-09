import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_pagination/chat_pagination_notifier.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_state/chat_state_notifier.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';

/// Utility class for clearing chat-related state and caches
class ChatStateCleaner {
  /// Clear all chat state and caches (useful for debugging or manual cleanup)
  static Future<void> clearAllChatState(WidgetRef ref) async {
    try {
      debugPrint('Starting manual chat state cleanup...');

      // Clear message caches
      final messageCache = ref.read(messageCacheServiceProvider);
      await messageCache.clearAllCaches();

      // Reset chat providers
      ref.invalidate(chatStateProvider);
      ref.invalidate(chatPaginationProvider);

      // Reset bubble states
      ref.invalidate(chatBubblesEnabledProvider);
      ref.invalidate(chatClosingAnimationProvider);
      ref.invalidate(herdClosingAnimationProvider);
      ref.invalidate(bubbleAnimationCallbackProvider);
      ref.invalidate(explosionRevealProvider);

      debugPrint('Manual chat state cleanup completed');
    } catch (e) {
      debugPrint('Error during manual chat state cleanup: $e');
      rethrow;
    }
  }

  /// Clear cache for a specific chat
  static Future<void> clearChatCache(WidgetRef ref, String chatId) async {
    try {
      debugPrint('Clearing cache for chat: $chatId');

      final messageCache = ref.read(messageCacheServiceProvider);
      await messageCache.clearChatCache(chatId);

      debugPrint('Cache cleared for chat: $chatId');
    } catch (e) {
      debugPrint('Error clearing cache for chat $chatId: $e');
      rethrow;
    }
  }

  /// Get cache statistics for debugging
  static Future<Map<String, dynamic>> getCacheStats(WidgetRef ref) async {
    try {
      final messageCache = ref.read(messageCacheServiceProvider);
      return await messageCache.getCacheStats();
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }
}

/// Provider for the chat state cleaner
final chatStateCleanerProvider = Provider<ChatStateCleaner>((ref) {
  return ChatStateCleaner();
});
