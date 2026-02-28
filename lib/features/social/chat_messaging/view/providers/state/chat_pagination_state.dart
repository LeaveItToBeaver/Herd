import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

class ChatPaginationState {
  final List<MessageModel> messages; // ascending order for UI convenience
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot?
      lastSnapshot; // last Firestore snapshot for pagination
  ChatPaginationState({
    required this.messages,
    required this.isLoadingMore,
    required this.hasMore,
    required this.lastSnapshot,
  });
  ChatPaginationState copyWith({
    List<MessageModel>? messages,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot? lastSnapshot,
  }) =>
      ChatPaginationState(
        messages: messages ?? this.messages,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        lastSnapshot: lastSnapshot ?? this.lastSnapshot,
      );
  factory ChatPaginationState.initial() => ChatPaginationState(
        messages: const [],
        isLoadingMore: false,
        hasMore: true,
        lastSnapshot: null,
      );
}
