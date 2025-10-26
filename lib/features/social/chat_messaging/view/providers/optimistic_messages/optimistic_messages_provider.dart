import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'optimistic_messages_notifier.dart';

final optimisticMessagesProvider = StateNotifierProvider.family<
    OptimisticMessagesNotifier,
    Map<String, MessageModel>,
    String>((ref, chatId) => OptimisticMessagesNotifier(chatId));
