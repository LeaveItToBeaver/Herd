import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    // Deduplicate by id and keep ascending order by timestamp
    final existing = List<MessageModel>.from(_memory[chatId] ?? []);
    final map = {for (final m in existing) m.id: m};
    for (final m in messages) {
      map[m.id] = m;
    }
    final merged = map.values.toList()
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
    DateTime _dt(dynamic v) => v == null
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
      timestamp: _dt(j['timestamp']),
      editedAt: j['editedAt'] != null ? _dt(j['editedAt']) : null,
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
          j['selfDestructTime'] != null ? _dt(j['selfDestructTime']) : null,
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
}
