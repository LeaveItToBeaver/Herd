import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';

/// Simple cache for chat messages (decrypted) and associated media files.
/// Stores one JSON file per chat containing an array of messages (ascending by timestamp)
/// plus individual media files by messageId.
class MessageCacheService {
  static final MessageCacheService _instance = MessageCacheService._internal();
  factory MessageCacheService() => _instance;
  MessageCacheService._internal();

  bool _initialized = false;
  Directory? _baseDir;
  Directory? _messagesDir;
  Directory? _mediaDir;

  // In-memory quick cache (not authoritative): chatId -> messages
  final Map<String, List<MessageModel>> _memory = {};

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true; // No disk cache on web
      return;
    }
    try {
      _baseDir = await getApplicationDocumentsDirectory();
      _messagesDir = Directory('${_baseDir!.path}/message_cache/messages');
      _mediaDir = Directory('${_baseDir!.path}/message_cache/media');
      await _messagesDir!.create(recursive: true);
      await _mediaDir!.create(recursive: true);
      _initialized = true;
    } catch (e) {
      debugPrint('MessageCacheService init error: $e');
    }
  }

  Future<List<MessageModel>> getCachedMessages(String chatId) async {
    if (!_initialized) await initialize();
    if (_memory.containsKey(chatId)) return _memory[chatId]!;
    if (kIsWeb) return [];
    final file = File('${_messagesDir!.path}/$chatId.json');
    if (!await file.exists()) return [];
    try {
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List;
      final messages =
          list.map((e) => _fromCacheJson(e as Map<String, dynamic>)).toList();
      _memory[chatId] = messages;
      return messages;
    } catch (e) {
      debugPrint('Read cache error ($chatId): $e');
      return [];
    }
  }

  Future<void> putMessages(String chatId, List<MessageModel> messages) async {
    if (!_initialized) await initialize();
    // Enhanced deduplication: merge existing and new messages by ID and content similarity
    final existing = List<MessageModel>.from(_memory[chatId] ?? []);
    final existingMap = {for (final m in existing) m.id: m};

    // NEW: Remove orphaned optimistic temp_* messages that have been replaced
    // by real server messages (their IDs will not appear in the incoming list).
    // This fixes duplicate outgoing messages after a cold restart.
    final incomingIds = messages.map((m) => m.id).toSet();
    existingMap.removeWhere(
        (id, m) => id.startsWith('temp_') && !incomingIds.contains(id));

    // Only add messages that aren't already cached or have newer timestamps
    for (final message in messages) {
      final existingMessage = existingMap[message.id];

      // For content duplicate check, only flag as duplicate if:
      // 1. Same content AND sender
      // 2. Timestamps are very close (within 5 seconds)
      // 3. AND it's not a temp/optimistic message being replaced by server message
      final isDuplicateContent = existing.any((existingMsg) =>
          existingMsg.id != message.id &&
          existingMsg.content == message.content &&
          existingMsg.senderId == message.senderId &&
          existingMsg.timestamp.difference(message.timestamp).abs().inSeconds <
              5 &&
          !message.id.startsWith('temp_') && // Don't block server messages
          !existingMsg.id
              .startsWith('temp_')); // Don't block over temp messages

      if (!isDuplicateContent) {
        if (existingMessage == null ||
            message.timestamp.isAfter(existingMessage.timestamp)) {
          existingMap[message.id] = message;
          if (existingMessage == null) {
            debugPrint('➕ Caching new message: ${message.id}');
          } else {
            debugPrint('🔄 Updating cached message: ${message.id}');
          }
        }
      } else {
        debugPrint('⚠️ Skipping duplicate content for message: ${message.id}');
      }
    }

    final merged = existingMap.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _memory[chatId] = merged;
    if (kIsWeb) return; // Skip disk on web
    final file = File('${_messagesDir!.path}/$chatId.json');
    try {
      final jsonList = merged.map(_toCacheJson).toList();
      await file.writeAsString(jsonEncode(jsonList), flush: true);
    } catch (e) {
      debugPrint('Write cache error ($chatId): $e');
    }
  }

  Future<void> upsertMessage(String chatId, MessageModel message) async {
    await putMessages(chatId, [message]);
  }

  Future<File?> cacheMediaBytes(
      {required String messageId,
      required Uint8List bytes,
      String? extension}) async {
    if (!_initialized) await initialize();
    if (kIsWeb) return null;
    final ext = extension ?? 'bin';
    final file = File('${_mediaDir!.path}/$messageId.$ext');
    try {
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Media cache write error: $e');
      return null;
    }
  }

  Future<File?> getCachedMediaFile(String messageId,
      {String? extension}) async {
    if (!_initialized) await initialize();
    if (kIsWeb) return null;
    final pattern = extension != null ? '$messageId.$extension' : messageId;
    final list = _mediaDir!.listSync().whereType<File>();
    try {
      return list.firstWhere((f) => f.path.split('/').last.startsWith(pattern));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _toCacheJson(MessageModel m) => {
        'id': m.id,
        'chatId': m.chatId,
        'senderId': m.senderId,
        'senderName': m.senderName,
        'senderProfileImage': m.senderProfileImage,
        'content': m.content,
        'type': m.type.toString().split('.').last,
        'timestamp': m.timestamp.millisecondsSinceEpoch,
        'editedAt': m.editedAt?.millisecondsSinceEpoch,
        'mediaUrl': m.mediaUrl,
        'thumbnailUrl': m.thumbnailUrl,
        'fileName': m.fileName,
        'fileSize': m.fileSize,
        'replyToMessageId': m.replyToMessageId,
        'forwardedFromUserId': m.forwardedFromUserId,
        'forwardedFromChatId': m.forwardedFromChatId,
        'readReceipts':
            m.readReceipts.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
        'reactions': m.reactions,
        'isEdited': m.isEdited,
        'isDeleted': m.isDeleted,
        'isPinned': m.isPinned,
        'isStarred': m.isStarred,
        'isForwarded': m.isForwarded,
        'isSelfDestructing': m.isSelfDestructing,
        'selfDestructTime': m.selfDestructTime?.millisecondsSinceEpoch,
        'quotedMessageId': m.quotedMessageId,
        'quotedMessageContent': m.quotedMessageContent,
        'latitude': m.latitude,
        'longitude': m.longitude,
        'locationName': m.locationName,
        'contactName': m.contactName,
        'contactPhone': m.contactPhone,
        'contactEmail': m.contactEmail,
      };

  MessageModel _fromCacheJson(Map<String, dynamic> j) {
    DateTime dt(dynamic v) => v == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(v as int);
    return MessageModel(
      id: j['id'] as String,
      chatId: j['chatId'] as String,
      senderId: j['senderId'] as String,
      senderName: j['senderName'] as String?,
      senderProfileImage: j['senderProfileImage'] as String?,
      content: j['content'] as String?,
      type: _parseType(j['type'] as String?),
      timestamp: dt(j['timestamp']),
      editedAt: j['editedAt'] != null ? dt(j['editedAt']) : null,
      mediaUrl: j['mediaUrl'] as String?,
      thumbnailUrl: j['thumbnailUrl'] as String?,
      fileName: j['fileName'] as String?,
      fileSize: j['fileSize'] as int?,
      replyToMessageId: j['replyToMessageId'] as String?,
      forwardedFromUserId: j['forwardedFromUserId'] as String?,
      forwardedFromChatId: j['forwardedFromChatId'] as String?,
      readReceipts: (j['readReceipts'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, DateTime.fromMillisecondsSinceEpoch(v as int))),
      reactions: (j['reactions'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      isEdited: j['isEdited'] == true,
      isDeleted: j['isDeleted'] == true,
      isPinned: j['isPinned'] == true,
      isStarred: j['isStarred'] == true,
      isForwarded: j['isForwarded'] == true,
      isSelfDestructing: j['isSelfDestructing'] == true,
      selfDestructTime:
          j['selfDestructTime'] != null ? dt(j['selfDestructTime']) : null,
      quotedMessageId: j['quotedMessageId'] as String?,
      quotedMessageContent: j['quotedMessageContent'] as String?,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      locationName: j['locationName'] as String?,
      contactName: j['contactName'] as String?,
      contactPhone: j['contactPhone'] as String?,
      contactEmail: j['contactEmail'] as String?,
    );
  }

  MessageType _parseType(String? raw) {
    if (raw == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == raw,
      orElse: () => MessageType.text,
    );
  }

  /// Clear all cached messages for a specific chat
  Future<void> clearChatCache(String chatId) async {
    if (!_initialized) await initialize();

    // Clear from memory
    _memory.remove(chatId);

    if (kIsWeb) return; // Skip disk operations on web

    try {
      final file = File('${_messagesDir!.path}/$chatId.json');
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Cleared cache for chat: $chatId');
      }
    } catch (e) {
      debugPrint('❌ Error clearing chat cache ($chatId): $e');
    }
  }

  /// Clear all cached messages and media files
  Future<void> clearAllCaches() async {
    if (!_initialized) await initialize();

    // Clear all in-memory data
    _memory.clear();

    if (kIsWeb) return; // Skip disk operations on web

    try {
      // Clear message cache files
      if (_messagesDir != null && await _messagesDir!.exists()) {
        final messageFiles = _messagesDir!.listSync().whereType<File>();
        for (final file in messageFiles) {
          await file.delete();
        }
        debugPrint('🗑️ Cleared all message cache files');
      }

      // Clear media cache files
      if (_mediaDir != null && await _mediaDir!.exists()) {
        final mediaFiles = _mediaDir!.listSync().whereType<File>();
        for (final file in mediaFiles) {
          await file.delete();
        }
        debugPrint('🗑️ Cleared all media cache files');
      }

      debugPrint('✅ All chat caches cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing all caches: $e');
    }
  }

  /// Clear cache for a specific user (when switching users)
  Future<void> clearUserCache(String userId) async {
    if (!_initialized) await initialize();

    // For now, clear all caches since we don't track per-user
    // In the future, we could implement per-user cache directories
    await clearAllCaches();
    debugPrint('🔄 Cleared cache for user: $userId');
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_initialized) await initialize();

    final stats = <String, dynamic>{
      'memoryCacheSize': _memory.length,
      'memoryChats': _memory.keys.toList(),
    };

    if (!kIsWeb && _messagesDir != null && _mediaDir != null) {
      try {
        final messageFiles =
            _messagesDir!.listSync().whereType<File>().toList();
        final mediaFiles = _mediaDir!.listSync().whereType<File>().toList();

        stats['diskMessageFiles'] = messageFiles.length;
        stats['diskMediaFiles'] = mediaFiles.length;

        int totalSize = 0;
        for (final file in [...messageFiles, ...mediaFiles]) {
          totalSize += await file.length();
        }
        stats['totalDiskSize'] = totalSize;
        stats['totalDiskSizeFormatted'] = _formatBytes(totalSize);
      } catch (e) {
        debugPrint('❌ Error getting cache stats: $e');
      }
    }

    return stats;
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Provider for the message cache service
final messageCacheServiceProvider = Provider<MessageCacheService>((ref) {
  return MessageCacheService();
});
