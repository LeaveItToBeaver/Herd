import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:herdapp/core/widgets/cached_video_player.dart';

class EncryptedMediaWidget extends ConsumerStatefulWidget {
  final MessageModel message;

  const EncryptedMediaWidget({super.key, required this.message});

  @override
  ConsumerState<EncryptedMediaWidget> createState() =>
      _EncryptedMediaWidgetState();
}

class _EncryptedMediaWidgetState extends ConsumerState<EncryptedMediaWidget> {
  File? _decryptedFile;
  bool _isLoading = false;
  double _progress = 0.0;
  bool _disposed = false;
  bool _loadedOnce = false; // prevent re-decrypt on rebuilds

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    if (_loadedOnce) return; // already loaded & cached
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authProvider);
      if (currentUser == null) return;

      // 1. Check cache service for existing decrypted media file
      final cache = ref.read(messageCacheServiceProvider);
      await cache.initialize();
      final cached = await cache.getCachedMediaFile(widget.message.id);
      if (cached != null && await cached.exists()) {
        if (!mounted) return;
        _decryptedFile = cached;
        _loadedOnce = true;
        setState(() => _isLoading = false);
        return;
      }

      // 2. If not cached, decrypt & download
      final messagesRepo = ref.read(messageRepositoryProvider);
      final file = await messagesRepo.getDecryptedMedia(
        message: widget.message,
        currentUserId: currentUser.uid,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _progress = progress);
        },
      );

      if (file != null) {
        // Store in message cache (keep original extension if possible)
        final ext = file.path.split('.').last;
        await cache.cacheMediaBytes(
          messageId: widget.message.id,
          bytes: await file.readAsBytes(),
          extension: ext,
        );
      }

      if (!mounted) return;
      _decryptedFile = file;
      _loadedOnce = true;
    } catch (e) {
      debugPrint('Failed to load encrypted media: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            SizedBox(height: 8),
            Text('Decrypting... ${(_progress * 100).toInt()}%'),
          ],
        ),
      );
    }

    if (_decryptedFile == null) {
      return Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.error, color: Colors.red),
      );
    }

    // Display the decrypted media
    if (widget.message.type == MessageType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _decryptedFile!,
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.message.type == MessageType.video) {
      // Use your existing CachedVideoPlayer widget with a file URL
      return CachedVideoPlayer(
        videoUrl: 'file://${_decryptedFile!.path}',
        autoPlay: false,
        showControls: true,
        aspectRatio: 16 / 9,
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 32),
          SizedBox(height: 8),
          Text(widget.message.fileName ?? 'File'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    // Do NOT delete cached decrypted file; leave it for reuse
    super.dispose();
  }
}
