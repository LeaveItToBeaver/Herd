import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatModel> chats,
    @Default({}) Map<String, List<MessageModel>> messages,
    @Default({}) Map<String, bool> loadingStates,
    ChatModel? currentChat,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChatState;
}

@freezed
abstract class MessageInputState with _$MessageInputState {
  const factory MessageInputState({
    @Default('') String text,
    @Default(false) bool isTyping,
    @Default(false) bool isSending,
    String? replyToMessageId,
    String? error,
  }) = _MessageInputState;
}
