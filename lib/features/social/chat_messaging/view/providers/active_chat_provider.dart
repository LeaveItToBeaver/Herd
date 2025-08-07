// Create a provider for active chats
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';

final activeChatBubblesProvider =
    StateNotifierProvider<ActiveChatBubblesNotifier, List<ChatModel>>((ref) {
  return ActiveChatBubblesNotifier(ref);
});

class ActiveChatBubblesNotifier extends StateNotifier<List<ChatModel>> {
  final Ref ref;

  ActiveChatBubblesNotifier(this.ref) : super([]) {
    loadUserChats();
  }

  Future<void> loadUserChats() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    final chatRepo = ref.read(chatRepositoryProvider);

    // Listen to user's chats
    chatRepo.getUserChats(currentUser.uid).listen((chats) {
      state = chats;
    });
  }

  void addChatBubble(ChatModel chat) {
    if (!state.any((c) => c.id == chat.id)) {
      state = [...state, chat];
    }
  }
}
