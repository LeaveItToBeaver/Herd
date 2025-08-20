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

  ActiveChatBubblesNotifier(this.ref) : super([]) {
    loadUserChats();
  }

  Future<void> loadUserChats() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    final chatRepo = ref.read(chatRepositoryProvider);

    // Cancel previous subscription if exists
    _chatSubscription?.cancel();

    // Listen to user's chats with real-time updates
    _chatSubscription = chatRepo.getUserChats(currentUser.uid).listen(
      (chats) {
        // Update state with new chats
        state = chats;
      },
      onError: (error) {
        print('Error loading chats: $error');
      },
    );
  }

  void addChatBubble(ChatModel chat) {
    // Check if chat already exists
    final existingIndex = state.indexWhere((c) => c.id == chat.id);

    if (existingIndex >= 0) {
      // Update existing chat
      final updatedChats = [...state];
      updatedChats[existingIndex] = chat;
      state = updatedChats;
    } else {
      // Add new chat
      state = [...state, chat];
    }
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
