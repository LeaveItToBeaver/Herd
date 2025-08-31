import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/state/chat_state.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';

// Verbose logging toggle for chat provider (non-error informational logs)
const bool _verboseChatProvider = false;
void _vc(String msg) { if (_verboseChatProvider && kDebugMode) debugPrint(msg); }

// Added back providers lost during refactor
final currentChatProvider =
    FutureProvider.family<ChatModel?, String>((ref, bubbleId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final currentUserAsync = ref.watch(currentUserProvider);
  final currentUser = currentUserAsync.when(
    data: (u) => u,
    loading: () => null,
    error: (_, __) => null,
  );
  if (currentUser == null) throw Exception('User not authenticated');
  return repo.getChatByBubbleId(bubbleId, currentUser.id);
});

final optimisticMessagesProvider = StateNotifierProvider.family<
    OptimisticMessagesNotifier,
    Map<String, MessageModel>,
    String>((ref, chatId) => OptimisticMessagesNotifier(chatId));

final messagesProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
        (ref, chatId) {
  return MessagesNotifier(ref, chatId);
});

/// Manages optimistic messages for a specific chat
class OptimisticMessagesNotifier
    extends StateNotifier<Map<String, MessageModel>> {
  final String chatId;

  OptimisticMessagesNotifier(this.chatId) : super({});

  void addOptimisticMessage(MessageModel message) {
    final newState = Map<String, MessageModel>.from(state);
    newState[message.id] = message;
    state = newState;
  _vc('➕ Added optimistic message: ${message.id}');
  }

  void updateMessageStatus(String messageId, MessageStatus status,
      {String? errorMessage}) {
    final message = state[messageId];
    if (message != null) {
      final updatedMessage = message.copyWith(status: status);
      final newState = Map<String, MessageModel>.from(state);
      newState[messageId] = updatedMessage;
      state = newState;
  _vc('🔄 Updated message $messageId status: ${status.displayText}');
      if (status == MessageStatus.delivered) {
        Future.delayed(const Duration(milliseconds: 800), () {
          removeOptimisticMessage(messageId);
        });
      }
    }
  }

  void removeOptimisticMessage(String messageId) {
    if (state.containsKey(messageId)) {
      final newState = Map<String, MessageModel>.from(state)..remove(messageId);
      state = newState;
  _vc('➖ Removed optimistic message: $messageId');
    }
  }

  void clearAll() {
    state = {};
  _vc('🧹 Cleared all optimistic messages for chat: $chatId');
  }

  int get pendingCount =>
      state.values.where((msg) => msg.status.isPending).length;
  int get failedCount => state.values.where((msg) => msg.status.isError).length;
}

// State for combined messages (cache + incremental fetch)
class MessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool hasLoadedFromCache;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.hasLoadedFromCache = false,
  });

  MessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? hasLoadedFromCache,
  }) =>
      MessagesState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        hasLoadedFromCache: hasLoadedFromCache ?? this.hasLoadedFromCache,
      );
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final Ref _ref;
  final String _chatId;
  Timer? _pollTimer; // periodic lightweight poll
  DateTime? _lastFetchedTimestamp; // high-watermark

  MessagesNotifier(this._ref, this._chatId) : super(const MessagesState()) {
    _initializeCacheFirst();
  }

  Future<void> _initializeCacheFirst() async {
    final cache = _ref.read(messageCacheServiceProvider);
    await cache.initialize();

    try {
      final cached = await cache.getCachedMessages(_chatId);
      if (cached.isNotEmpty) {
        final sorted = _sortMessages(cached);
        state = state.copyWith(
          messages: sorted,
          hasLoadedFromCache: true,
        );
        _lastFetchedTimestamp = sorted.last.timestamp;
        debugPrint(
            '📱 Loaded ${sorted.length} cached messages for chat: $_chatId');
      }
    } catch (e) {
      debugPrint('⚠️ Cache load failed: $e');
    }

    // Initial incremental fetch (will fetch all if no cache watermark)
    await _fetchNewMessages();

    // Periodic poll (adjust interval as needed)
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      await _fetchNewMessages();
    });
  }

  Future<void> _fetchNewMessages() async {
    try {
      final repo = _ref.read(messageRepositoryProvider);
      final cache = _ref.read(messageCacheServiceProvider);
      final latestTs = _lastFetchedTimestamp;

      final newMessages = await repo.fetchLatestMessages(
        _chatId,
        afterTimestamp: latestTs,
        limit: 50,
      );

      if (newMessages.isEmpty) return;

      // Remove replaced optimistic messages
      final optimistic = _ref.read(optimisticMessagesProvider(_chatId));
      final optimisticNotifier =
          _ref.read(optimisticMessagesProvider(_chatId).notifier);
      final toRemove = <String>[];
      for (final serverMsg in newMessages) {
        for (final entry in optimistic.entries) {
          if (_messagesMatch(entry.value, serverMsg)) {
            toRemove.add(entry.key);
          }
        }
      }
      for (final id in toRemove) {
        optimisticNotifier.removeOptimisticMessage(id);
      }

      final merged = [...state.messages, ...newMessages];
      final sorted = _sortMessages(merged);
      state = state.copyWith(messages: sorted);
      await cache.putMessages(_chatId, sorted);
      _lastFetchedTimestamp = sorted.last.timestamp;
  _vc('✅ Added ${newMessages.length} new messages (watermark=${_lastFetchedTimestamp!.toIso8601String()})');
    } catch (e) {
      debugPrint('❌ Incremental fetch error: $e');
    }
  }

  // Full refetch no longer automatically triggered; provide manual method if diagnostic needed.
  Future<void> refetchAllMessagesForDebug() async {
    try {
      final repo = _ref.read(messageRepositoryProvider);
      final cache = _ref.read(messageCacheServiceProvider);
      final all = await repo.fetchAllMessages(_chatId);
      final sorted = _sortMessages(all);
      state = state.copyWith(messages: sorted);
      await cache.putMessages(_chatId, sorted);
      _lastFetchedTimestamp = sorted.isNotEmpty ? sorted.last.timestamp : null;
  _vc('🔄 Manual refetch loaded ${sorted.length} messages');
    } catch (e) {
      debugPrint('❌ Manual refetch error: $e');
    }
  }

  // Helper method to check if messages match (for optimistic -> server replacement)
  bool _messagesMatch(MessageModel optimistic, MessageModel server) {
    return optimistic.content == server.content &&
        optimistic.senderId == server.senderId &&
        optimistic.chatId == server.chatId &&
        optimistic.timestamp.difference(server.timestamp).abs().inSeconds <
            10; // Allow 10 sec difference
  }

  // Add message optimistically (like appending to todo list)
  void addOptimisticMessage(MessageModel message) async {
    final newMessages = [...state.messages, message];
    final sortedMessages = _sortMessages(newMessages);
    state = state.copyWith(messages: sortedMessages);

    // Update cache with the optimistic message
    final cache = _ref.read(messageCacheServiceProvider);
    await cache.putMessages(_chatId, sortedMessages);

    debugPrint('➕ Added optimistic message locally: ${message.id}');
  }

  // Update message status without removing it
  void updateMessageStatus(String messageId, MessageStatus status) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(status: status);
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
    debugPrint(
        '🔄 Updated message status locally: $messageId -> ${status.displayText}');
  }

  // Replace temporary ID with server ID (when server responds)
  void replaceOptimisticMessage(
      String tempId, MessageModel serverMessage) async {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == tempId) {
        return serverMessage;
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: _sortMessages(updatedMessages));

    // Update cache with the replaced message
    final cache = _ref.read(messageCacheServiceProvider);
    await cache.putMessages(_chatId, updatedMessages);

    debugPrint(
        '🔄 Replaced optimistic message: $tempId -> ${serverMessage.id}');
  }

  List<MessageModel> _sortMessages(List<MessageModel> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

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

  _vc('✅ Marked chat $chatId as read for user ${authUser.uid}');
    } catch (e) {
      debugPrint('❌ Failed to mark chat as read: $e');
    }
  }

  /// Force clear all message caches for debugging
  Future<void> clearAllMessageCaches() async {
    try {
      final cache = _ref.read(messageCacheServiceProvider);
      await cache.clearAllCaches();
  _vc('🗑️ Cleared all message caches');
    } catch (e) {
      debugPrint('❌ Failed to clear caches: $e');
    }
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

    // Set sending state immediately
    state = state.copyWith(isSending: true, error: null);

    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);
      final messagesNotifier = _ref.read(messagesProvider(_chatId).notifier);

      // Get current authenticated user
      final authUser = _ref.read(authProvider);
      final currentUserAsync = _ref.read(currentUserProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      // Handle AsyncValue properly
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (currentUser == null) {
        throw Exception('User profile not loaded. Please wait and try again.');
      }

      // 1. Create optimistic message with temporary ID
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final senderName =
          '${currentUser.firstName} ${currentUser.lastName}'.trim();

      final optimisticMessage = MessageModel(
        id: tempId,
        chatId: _chatId,
        senderId: authUser.uid,
        senderName: senderName,
        senderProfileImage: currentUser.profileImageURL,
        content: content,
        type: MessageType.text,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
        replyToMessageId: state.replyToMessageId,
      );

      // 2. Add to UI immediately (like appending to todo list)
      messagesNotifier.addOptimisticMessage(optimisticMessage);

      // 3. Clear input immediately for better UX - THIS IS KEY!
      state = state.copyWith(
        text: '',
        isSending: false, // Allow typing immediately
        replyToMessageId: null,
        error: null,
      );

      // 4. Send to Firebase in background (don't await here to prevent blocking)
      _sendMessageInBackground(
        messagesRepo,
        messagesNotifier,
        tempId,
        optimisticMessage,
        authUser.uid,
        content,
        senderName,
      );
    } catch (error) {
      // Handle initial setup errors (auth, user loading, etc.)
      state = state.copyWith(
        isSending: false,
        error: error.toString(),
      );
    }
  }

  /// Send message in background without blocking UI
  void _sendMessageInBackground(
    MessageRepository messagesRepo,
    MessagesNotifier messagesNotifier,
    String tempId,
    MessageModel optimisticMessage,
    String senderId,
    String content,
    String senderName,
  ) async {
    try {
      final sentMessage = await messagesRepo.sendMessage(
        chatId: _chatId,
        senderId: senderId,
        content: content,
        senderName: senderName,
        replyToMessageId: optimisticMessage.replyToMessageId,
      );

      // Replace temp ID with server ID (no UI disruption)
      messagesNotifier.replaceOptimisticMessage(tempId, sentMessage);

  _vc('✅ Message sent successfully: ${sentMessage.id}');
    } catch (error) {
      // Mark as failed if sending failed
      messagesNotifier.updateMessageStatus(tempId, MessageStatus.failed);

      debugPrint('❌ Failed to send message: $error');

      // Show error in input state for user awareness
      state = state.copyWith(error: 'Failed to send message. Tap to retry.');
    }
  }

  /// Retry sending a failed message
  Future<void> retryMessage(String messageId) async {
    final messagesNotifier = _ref.read(messagesProvider(_chatId).notifier);
    final currentState = _ref.read(messagesProvider(_chatId));
    final message =
        currentState.messages.where((m) => m.id == messageId).firstOrNull;

    if (message == null || message.status != MessageStatus.failed) {
      return;
    }

    // Update status to sending
    messagesNotifier.updateMessageStatus(messageId, MessageStatus.sending);

    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);

      final sentMessage = await messagesRepo.sendMessage(
        chatId: message.chatId,
        senderId: message.senderId,
        content: message.content ?? '',
        senderName: message.senderName,
        replyToMessageId: message.replyToMessageId,
      );

      // Replace with server message
      messagesNotifier.replaceOptimisticMessage(messageId, sentMessage);
    } catch (error) {
      // Mark as failed again
      messagesNotifier.updateMessageStatus(messageId, MessageStatus.failed);
      debugPrint('❌ Retry failed: $error');
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
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      final messagesRepo = _ref.read(messageRepositoryProvider);
      final authUser = _ref.read(authProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await messagesRepo.softDeleteMessage(chatId, messageId, authUser.uid);
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
