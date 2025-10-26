import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

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
