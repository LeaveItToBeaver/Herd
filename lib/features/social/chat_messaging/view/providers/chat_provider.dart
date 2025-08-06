import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/state/chat_state.dart';
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
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getChatMessages(chatId);
});

// Provider for getting an individual message by ID
final messageProvider =
    StreamProvider.family<MessageModel?, String>((ref, messageId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessageById(messageId);
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
      final repository = _ref.read(chatRepositoryProvider);

      // In a real app, you'd get the current user from auth provider
      await repository.sendMessage(
        chatId: _chatId,
        senderId: 'current_user',
        content: content,
        senderName: 'You',
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
}
