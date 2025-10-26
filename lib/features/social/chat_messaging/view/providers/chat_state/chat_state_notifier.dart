import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../state/chat_state.dart';

// Verbose logging toggle for chat provider (non-error informational logs)
const bool _verboseChatProvider = false;
void _vc(String msg) {
  if (_verboseChatProvider && kDebugMode) debugPrint(msg);
}

class ChatStateNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatStateNotifier(this._ref) : super(const ChatState());

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // In a real app, this would load the user's chats from the repository
      // For MVP, we'll create some mock data
      final mockChats = <ChatModel>[
        ChatModel(
          id: 'chat_0',
          otherUserId: 'user_0',
          otherUserName: 'User 1',
          otherUserUsername: '@user1',
          lastMessage: 'Hey there! 👋',
          lastMessageTimestamp:
              DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 2,
        ),
        ChatModel(
          id: 'chat_1',
          otherUserId: 'user_1',
          otherUserName: 'User 2',
          otherUserUsername: '@user2',
          lastMessage: 'How are you doing?',
          lastMessageTimestamp:
              DateTime.now().subtract(const Duration(hours: 3)),
          unreadCount: 0,
        ),
      ];

      state = state.copyWith(
        chats: mockChats,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void setCurrentChat(ChatModel? chat) {
    state = state.copyWith(currentChat: chat);

    // Auto-mark messages as read when opening a chat
    if (chat != null) {
      _markChatAsRead(chat.id);
    }
  }

  Future<void> _markChatAsRead(String chatId) async {
    try {
      final authUser = _ref.read(authProvider);
      if (authUser == null) return;

      final messagesRepo = _ref.read(messageRepositoryProvider);
      await messagesRepo.markMessagesAsRead(chatId, authUser.uid);

      _vc('Marked chat $chatId as read for user ${authUser.uid}');
    } catch (e) {
      debugPrint('Failed to mark chat as read: $e');
    }
  }

  /// Force clear all message caches for debugging
  Future<void> clearAllMessageCaches() async {
    try {
      final cache = _ref.read(messageCacheServiceProvider);
      await cache.clearAllCaches();
      _vc('Cleared all message caches');
    } catch (e) {
      debugPrint('Failed to clear caches: $e');
    }
  }
}
