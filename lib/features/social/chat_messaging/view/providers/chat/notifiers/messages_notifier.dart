import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../state/messages_state.dart';
import 'optimistic_messages_notifier.dart';

part 'messages_notifier.g.dart';

// Verbose logging toggle for chat provider (non-error informational logs)
const bool _verboseChatProvider = false;
void _vc(String msg) {
  if (_verboseChatProvider && kDebugMode) debugPrint(msg);
}

@riverpod
class Messages extends _$Messages {
  late String _chatId;
  Timer? _pollTimer; // periodic lightweight poll
  DateTime? _lastFetchedTimestamp; // high-watermark

  @override
  MessagesState build(String chatId) {
    _chatId = chatId;

    // Clean up timer on dispose
    ref.onDispose(() {
      _pollTimer?.cancel();
    });

    _initializeCacheFirst();
    return const MessagesState();
  }

  Future<void> _initializeCacheFirst() async {
    final cache = ref.read(messageCacheServiceProvider);
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
            'Loaded ${sorted.length} cached messages for chat: $_chatId');
      }
    } catch (e) {
      debugPrint('Cache load failed: $e');
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
      final repo = ref.read(messageRepositoryProvider);
      final cache = ref.read(messageCacheServiceProvider);
      final latestTs = _lastFetchedTimestamp;

      // Get current user ID for message filtering
      final currentUser = ref.read(authProvider);
      final currentUserId = currentUser?.uid;

      final newMessages = await repo.fetchLatestMessages(
        _chatId,
        afterTimestamp: latestTs,
        limit: 50,
        currentUserId: currentUserId,
      );

      if (newMessages.isEmpty) return;

      // Remove replaced optimistic messages
      final optimistic = ref.read(optimisticMessagesProvider(_chatId));
      final optimisticNotifier =
          ref.read(optimisticMessagesProvider(_chatId).notifier);
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
      _vc('Added ${newMessages.length} new messages (watermark=${_lastFetchedTimestamp!.toIso8601String()})');
    } catch (e) {
      debugPrint('Incremental fetch error: $e');
    }
  }

  // Full refetch no longer automatically triggered; provide manual method if diagnostic needed.
  Future<void> refetchAllMessagesForDebug() async {
    try {
      final repo = ref.read(messageRepositoryProvider);
      final cache = ref.read(messageCacheServiceProvider);
      final all = await repo.fetchAllMessages(_chatId);
      final sorted = _sortMessages(all);
      state = state.copyWith(messages: sorted);
      await cache.putMessages(_chatId, sorted);
      _lastFetchedTimestamp = sorted.isNotEmpty ? sorted.last.timestamp : null;
      _vc('Manual refetch loaded ${sorted.length} messages');
    } catch (e) {
      debugPrint('Manual refetch error: $e');
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
    final cache = ref.read(messageCacheServiceProvider);
    await cache.putMessages(_chatId, sortedMessages);

    debugPrint('Added optimistic message locally: ${message.id}');
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
        'Updated message status locally: $messageId -> ${status.displayText}');
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
    final cache = ref.read(messageCacheServiceProvider);
    await cache.putMessages(_chatId, updatedMessages);

    debugPrint('Replaced optimistic message: $tempId -> ${serverMessage.id}');
  }

  List<MessageModel> _sortMessages(List<MessageModel> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }
}
