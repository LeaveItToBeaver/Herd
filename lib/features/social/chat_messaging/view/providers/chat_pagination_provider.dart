final chatPaginationProvider = StateNotifierProvider.family<
    ChatPaginationNotifier, ChatPaginationState, String>((ref, chatId) {
  final repo = ref.watch(messageRepositoryProvider);
  final cache = ref.watch(messageCacheServiceProvider);
  final mediaHandler = ref.watch(encryptedMediaHandlerProvider);
  return ChatPaginationNotifier(
      chatId: chatId, repo: repo, cache: cache, mediaHandler: mediaHandler);
});

class ChatPaginationNotifier extends StateNotifier<ChatPaginationState> {
  final String chatId;
  final MessageRepository repo;
  final MessageCacheService cache;
  final EncryptedMediaMessageHandler _mediaHandler;
  ChatPaginationNotifier(
      {required this.chatId,
      required this.repo,
      required this.cache,
      required EncryptedMediaMessageHandler mediaHandler})
      : _mediaHandler = mediaHandler,
        super(ChatPaginationState.initial()) {
    _loadInitial();
  }

  bool _initialLoaded = false;

  Future<void> _loadInitial() async {
    if (_initialLoaded) return;
    // Load cache first
    final cached = await cache.getCachedMessages(chatId);
    if (cached.isNotEmpty) {
      state = state.copyWith(messages: cached); // assume ascending already
    }
    // Fetch first page (descending), then merge & resort ascending
    final page =
        await repo.fetchMessagePage(chatId: chatId, limit: repo.pageSize);
    final descending = page; // already newest first
    final ascending = List<MessageModel>.from(descending)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final merged = _mergeAscending(state.messages, ascending);
    await cache.putMessages(chatId, merged);
    state =
        state.copyWith(messages: merged, hasMore: page.length == repo.pageSize);
    _initialLoaded = true;
  }

  /// Get cached participants for a chat
  Future<List<String>> _getCachedParticipants(
      String chatId, String currentUserId) async {
    try {
      if (chatId.contains('_')) {
        final parts = chatId.split('_');
        if (parts.length == 2) {
          return [parts[0], parts[1]];
        }
      }

      // Fallback - at minimum we know the current user is a participant
      return [currentUserId];
    } catch (e) {
      return [currentUserId];
    }
  }

  List<MessageModel> _mergeAscending(
      List<MessageModel> current, List<MessageModel> incoming) {
    final map = {for (final m in current) m.id: m};
    for (final m in incoming) {
      map[m.id] = m;
    }
    final list = map.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      // Determine last snapshot by querying one doc (inefficient placeholder) – improvement: retain snapshots in state.
      // For legacy path we need lastDocument; for now we re-query last N messages and use startAfter.
      final page =
          await repo.fetchMessagePage(chatId: chatId, limit: repo.pageSize);
      // TODO: Implement real pagination using retained last DocumentSnapshot.
      final existingIds = state.messages.map((m) => m.id).toSet();
      final newOnes = page.where((m) => !existingIds.contains(m.id)).toList();
      if (newOnes.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }
      final asc = List<MessageModel>.from(newOnes)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final merged = _mergeAscending(state.messages, asc);
      await cache.putMessages(chatId, merged);
      state = state.copyWith(
          messages: merged,
          isLoadingMore: false,
          hasMore: newOnes.length == repo.pageSize);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
    }
  }

  Future<MessageModel> sendEncryptedMedia({
    required String chatId,
    required String senderId,
    required File mediaFile,
    required MessageType mediaType,
    String? caption,
    String? replyToMessageId,
    String? senderName,
    Function(double)? onProgress,
  }) async {
    final participants = await _getCachedParticipants(chatId, senderId);

    return await _mediaHandler.sendEncryptedMediaMessage(
      chatId: chatId,
      senderId: senderId,
      mediaFile: mediaFile,
      mediaType: mediaType,
      participants: participants,
      caption: caption,
      replyToMessageId: replyToMessageId,
      senderName: senderName,
      onUploadProgress: onProgress,
    );
  }

  /// Decrypt and download media
  Future<File?> getDecryptedMedia({
    required MessageModel message,
    required String currentUserId,
    Function(double)? onProgress,
  }) async {
    final participants =
        await _getCachedParticipants(message.chatId, currentUserId);

    final mediaInfo = await _mediaHandler.decryptMediaMessage(
      message: message,
      currentUserId: currentUserId,
      participants: participants,
    );

    if (mediaInfo != null) {
      return await _mediaHandler.downloadDecryptedMedia(
        mediaInfo: mediaInfo,
        onProgress: onProgress,
      );
    }

    return null;
  }
}
