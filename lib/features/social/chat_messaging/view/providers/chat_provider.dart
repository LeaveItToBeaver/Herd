import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/state/chat_state.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/handlers/encrypted_media_handler.dart';

// Verbose logging toggle for chat provider (non-error informational logs)
const bool _verboseChatProvider = false;
void _vc(String msg) {
  if (_verboseChatProvider && kDebugMode) debugPrint(msg);
}

// Added back providers lost during refactor
final currentChatProvider =
    FutureProvider.family<ChatModel?, String>((ref, bubbleId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final currentUserAsync = ref.watch(currentUserProvider);
  final currentUser = currentUserAsync.when(
    data: (u) => u,
    loading: () => null,
    error: (_, __) => null,
  );
  if (currentUser == null) throw Exception('User not authenticated');
  return repo.getChatByBubbleId(bubbleId, currentUser.id);
});
