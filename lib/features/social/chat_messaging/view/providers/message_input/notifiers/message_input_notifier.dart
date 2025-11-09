import 'package:flutter/foundation.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat/notifiers/messages_notifier.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
import '../state/message_input_state.dart';

part 'message_input_notifier.g.dart';

// Verbose logging toggle for chat provider (non-error informational logs)
const bool _verboseChatProvider = false;
void _vc(String msg) {
  if (_verboseChatProvider && kDebugMode) debugPrint(msg);
}

@riverpod
class MessageInput extends _$MessageInput {
  late String _chatId;

  @override
  MessageInputState build(String chatId) {
    _chatId = chatId;
    return const MessageInputState();
  }

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
      final messagesRepo = ref.read(messageRepositoryProvider);
      final messagesNotifier = ref.read(messagesProvider(_chatId).notifier);

      // Get current authenticated user
      final authUser = ref.read(authProvider);
      final currentUserAsync = ref.read(currentUserProvider);

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
    dynamic messagesNotifier,
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

      _vc('Message sent successfully: ${sentMessage.id}');
    } catch (error) {
      // Mark as failed if sending failed
      messagesNotifier.updateMessageStatus(tempId, MessageStatus.failed);

      debugPrint('Failed to send message: $error');

      // Show error in input state for user awareness
      state = state.copyWith(error: 'Failed to send message. Tap to retry.');
    }
  }

  /// Retry sending a failed message
  Future<void> retryMessage(String messageId) async {
    final messagesNotifier = ref.read(messagesProvider(_chatId).notifier);
    final currentState = ref.read(messagesProvider(_chatId));
    final message =
        currentState.messages.where((m) => m.id == messageId).firstOrNull;

    if (message == null || message.status != MessageStatus.failed) {
      return;
    }

    // Update status to sending
    messagesNotifier.updateMessageStatus(messageId, MessageStatus.sending);

    try {
      final messagesRepo = ref.read(messageRepositoryProvider);

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
      debugPrint('Retry failed: $error');
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
      final messagesRepo = ref.read(messageRepositoryProvider);
      final authUser = ref.read(authProvider);

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
      final messagesRepo = ref.read(messageRepositoryProvider);
      final authUser = ref.read(authProvider);

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
      final messagesRepo = ref.read(messageRepositoryProvider);
      final authUser = ref.read(authProvider);

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      await messagesRepo.softDeleteMessage(chatId, messageId, authUser.uid);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }
}
