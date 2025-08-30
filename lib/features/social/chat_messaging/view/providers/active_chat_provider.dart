import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'dart:async';

final activeChatBubblesProvider =
    StateNotifierProvider<ActiveChatBubblesNotifier, List<ChatModel>>((ref) {
  return ActiveChatBubblesNotifier(ref);
});

class ActiveChatBubblesNotifier extends StateNotifier<List<ChatModel>> {
  final Ref ref;
  StreamSubscription? _chatSubscription;
  String? _currentUserId; // Track current user to prevent unnecessary reloads

  ActiveChatBubblesNotifier(this.ref) : super([]) {
    loadUserChats();

    // Listen to auth changes to reload chats when user changes
    ref.listen(authProvider, (previous, next) {
      final newUserId = next?.uid;
      if (newUserId != _currentUserId) {
        debugPrint('👤 User changed from $_currentUserId to $newUserId');
        _currentUserId = newUserId;
        loadUserChats();
      }
    });
  }

  Future<void> loadUserChats() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      debugPrint('❌ No current user, clearing chats');
      _currentUserId = null;
      state = [];
      return;
    }

    // Prevent reloading if same user
    if (_currentUserId == currentUser.uid && _chatSubscription != null) {
      debugPrint('⏭️ Same user, skipping reload: ${currentUser.uid}');
      return;
    }

    _currentUserId = currentUser.uid;
    final chatRepo = ref.read(chatRepositoryProvider);

    // Cancel previous subscription if exists
    _chatSubscription?.cancel();

    debugPrint('🔄 Loading chats for user: ${currentUser.uid}');

    // Listen to user's chats with real-time updates
    _chatSubscription = chatRepo.getUserChats(currentUser.uid).listen(
      (chats) {
        debugPrint('📱 Received ${chats.length} chats from stream');

        // Debug: debugPrint chat IDs to check for duplicates
        final chatIds = chats.map((c) => c.id).toList();
        final uniqueIds = chatIds.toSet();

        if (chatIds.length != uniqueIds.length) {
          debugPrint('⚠️ WARNING: Duplicate chat IDs detected!');
          debugPrint('All IDs: $chatIds');
          debugPrint('Unique IDs: $uniqueIds');

          // Remove duplicates by ID (keep latest)
          final Map<String, ChatModel> uniqueChats = {};
          for (final chat in chats) {
            uniqueChats[chat.id] = chat;
          }
          state = uniqueChats.values.toList();
        } else {
          // No duplicates, update normally
          state = chats;
        }

        debugPrint('✅ Updated state with ${state.length} unique chats');
      },
      onError: (error) {
        debugPrint('❌ Error loading chats: $error');
        // Don't clear state on error, keep existing chats
      },
    );
  }

  void addChatBubble(ChatModel chat) {
    debugPrint('➕ Adding chat bubble: ${chat.id}');

    // Check if chat already exists
    final existingIndex = state.indexWhere((c) => c.id == chat.id);

    if (existingIndex >= 0) {
      debugPrint('🔄 Updating existing chat: ${chat.id}');
      // Update existing chat
      final updatedChats = [...state];
      updatedChats[existingIndex] = chat;
      state = updatedChats;
    } else {
      debugPrint('🆕 Adding new chat: ${chat.id}');
      // Add new chat
      state = [...state, chat];
    }

    debugPrint('📊 Total chats after add: ${state.length}');
  }

  void removeChatBubble(String chatId) {
    state = state.where((chat) => chat.id != chatId).toList();
  }

  void updateChatBubble(ChatModel updatedChat) {
    final index = state.indexWhere((chat) => chat.id == updatedChat.id);
    if (index >= 0) {
      final updatedChats = [...state];
      updatedChats[index] = updatedChat;
      state = updatedChats;
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
