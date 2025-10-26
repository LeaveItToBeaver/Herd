import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'active_chat_notifier.dart';

final activeChatBubblesProvider =
    StateNotifierProvider<ActiveChatBubblesNotifier, List<ChatModel>>((ref) {
  return ActiveChatBubblesNotifier(ref);
});
