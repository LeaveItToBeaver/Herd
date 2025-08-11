import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/state/chat_state.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';

// Provider for current chat based on bubble ID
final currentChatProvider =
    FutureProvider.family<ChatModel?, String>((ref, bubbleId) async {
  final repository = ref.watch(chatRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  return await repository.getChatByBubbleId(bubbleId, currentUser.userId);
});

final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final messagesRepo = ref.watch(messageRepositoryProvider);
  final cache = ref.watch(messageCacheServiceProvider);
  // Prime cache (async) – UI may show stale cached first then stream updates.
  () async {
    final cached = await cache.getCachedMessages(chatId);
    if (cached.isNotEmpty) {
      // Inject into state map if using ChatState later (optional hook)
    }
  }();
  return messagesRepo.getChatMessages(chatId);
});

// Provider for getting an individual message by ID
// Use format "chatId:messageId" for the parameter
final messageProvider =
    StreamProvider.family<MessageModel?, String>((ref, chatMessageKey) {
  final messagesRepo = ref.watch(messageRepositoryProvider);
  final parts = chatMessageKey.split(':');
  if (parts.length != 2) {
    return Stream.value(null);
  }
  final chatId = parts[0];
  final messageId = parts[1];
  return messagesRepo.getMessageById(chatId, messageId);
});

// Provider for chat state
final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier(ref);
});

// Provider for message input state
final messageInputProvider = StateNotifierProvider.family<MessageInputNotifier,
    MessageInputState, String>((ref, chatId) {
  return MessageInputNotifier(ref, chatId);
});

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
  }
}

class MessageInputNotifier extends StateNotifier<MessageInputState> {
  final Ref _ref;
  final String _chatId;

  MessageInputNotifier(this._ref, this._chatId)
      : super(const MessageInputState());

  void updateText(String text) {
    state = state.copyWith(text: text);
  }

  void setTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }

  void setReplyTo(String? messageId) {
    state = state.copyWith(replyToMessageId: messageId);
  }

  Future<void> sendMessage() async {
    if (state.text.trim().isEmpty || state.isSending) return;

    final content = state.text.trim();
    state = state.copyWith(isSending: true, error: null);

    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);

      // Get current authenticated user
      final authUser = _ref.read(authProvider);
      final currentUser = _ref.read(currentUserProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      if (currentUser == null) {
        throw Exception('User profile not found');
      }

      // Send message with complete user data
      await messagesRepo.sendMessage(
        chatId: _chatId,
        senderId: authUser.uid, // Use actual authenticated user ID
        content: content,
        senderName: '${currentUser.firstName} ${currentUser.lastName}'.trim(),
        replyToMessageId: state.replyToMessageId,
        // Additional message data could include:
        // type: MessageType.text, // Default type
        // mediaData: null, // For future media messages
      );

      state = state.copyWith(
        text: '',
        isSending: false,
        replyToMessageId: null,
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        error: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Toggle a reaction on a message
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);
      final authUser = _ref.read(authProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await messagesRepo.toggleMessageReaction(
        messageId: messageId,
        userId: authUser.uid,
        emoji: emoji,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  /// Edit a message
  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);
      final authUser = _ref.read(authProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await messagesRepo.editMessage(
        messageId: messageId,
        newContent: newContent,
        userId: authUser.uid,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);
      final authUser = _ref.read(authProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await messagesRepo.deleteMessage(
        messageId: messageId,
        userId: authUser.uid,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }
}

// Pagination controller state
class ChatPaginationState {
  final List<MessageModel> messages; // ascending order for UI convenience
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot?
      lastSnapshot; // last Firestore snapshot for pagination
  ChatPaginationState({
    required this.messages,
    required this.isLoadingMore,
    required this.hasMore,
    required this.lastSnapshot,
  });
  ChatPaginationState copyWith({
    List<MessageModel>? messages,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot? lastSnapshot,
  }) =>
      ChatPaginationState(
        messages: messages ?? this.messages,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        lastSnapshot: lastSnapshot ?? this.lastSnapshot,
      );
  factory ChatPaginationState.initial() => ChatPaginationState(
        messages: const [],
        isLoadingMore: false,
        hasMore: true,
        lastSnapshot: null,
      );
}

final chatPaginationProvider = StateNotifierProvider.family<
    ChatPaginationNotifier, ChatPaginationState, String>((ref, chatId) {
  final repo = ref.watch(messageRepositoryProvider);
  final cache = ref.watch(messageCacheServiceProvider);
  return ChatPaginationNotifier(chatId: chatId, repo: repo, cache: cache);
});

class ChatPaginationNotifier extends StateNotifier<ChatPaginationState> {
  final String chatId;
  final MessageRepository repo;
  final MessageCacheService cache;
  ChatPaginationNotifier(
      {required this.chatId, required this.repo, required this.cache})
      : super(ChatPaginationState.initial()) {
    _loadInitial();
  }

  bool _initialLoaded = false;

  Future<void> _loadInitial() async {
    if (_initialLoaded) return;
    // Load cache first
    final cached = await cache.getCachedMessages(chatId);
    if (cached.isNotEmpty) {
      state = state.copyWith(messages: cached); // assume ascending already
    }
    // Fetch first page (descending), then merge & resort ascending
    final page =
        await repo.fetchMessagePage(chatId: chatId, limit: repo.pageSize);
    final descending = page; // already newest first
    final ascending = List<MessageModel>.from(descending)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final merged = _mergeAscending(state.messages, ascending);
    await cache.putMessages(chatId, merged);
    state =
        state.copyWith(messages: merged, hasMore: page.length == repo.pageSize);
    _initialLoaded = true;
  }

  List<MessageModel> _mergeAscending(
      List<MessageModel> current, List<MessageModel> incoming) {
    final map = {for (final m in current) m.id: m};
    for (final m in incoming) {
      map[m.id] = m;
    }
    final list = map.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      // Determine last snapshot by querying one doc (inefficient placeholder) – improvement: retain snapshots in state.
      // For legacy path we need lastDocument; for now we re-query last N messages and use startAfter.
      // Simplification: not maintaining DocumentSnapshot chain here -> scope for future enhancement.
      final page = await repo.fetchMessagePage(
          chatId: chatId,
          limit: repo.pageSize); // currently always first page again
      // TODO: Implement real pagination using retained last DocumentSnapshot.
      // For now, pretend exhausted if page smaller than size OR no new IDs.
      final existingIds = state.messages.map((m) => m.id).toSet();
      final newOnes = page.where((m) => !existingIds.contains(m.id)).toList();
      if (newOnes.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }
      final asc = List<MessageModel>.from(newOnes)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final merged = _mergeAscending(state.messages, asc);
      await cache.putMessages(chatId, merged);
      state = state.copyWith(
          messages: merged,
          isLoadingMore: false,
          hasMore: newOnes.length == repo.pageSize);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }
}
