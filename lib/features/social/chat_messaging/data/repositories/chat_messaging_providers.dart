import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/e2ee_key_manager.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/media_crypto_service.dart';
import 'package:herdapp/features/social/chat_messaging/utils/secure_media_service.dart';
import 'package:herdapp/features/social/chat_messaging/data/handlers/encrypted_media_handler.dart';
import 'package:herdapp/features/user/user_management/data/repositories/user_block_repository.dart';

final chatCryptoServiceProvider = Provider<ChatCryptoService>((ref) {
  // Use more stable Android options for secure storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  return ChatCryptoService(secureStorage);
});

final e2eeKeyManagerProvider = Provider<E2EEKeyManager>((ref) {
  final cryptoService = ref.watch(chatCryptoServiceProvider);
  // Use same secure storage configuration
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  return E2EEKeyManager(
    secureStorage,
    cryptoService,
    FirebaseFirestore.instance,
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ChatRepository(FirebaseFirestore.instance, userRepo);
});

final mediaCryptoServiceProvider = Provider<MediaCryptoService>((ref) {
  return MediaCryptoService();
});

final secureMediaServiceProvider = Provider<SecureMediaService>((ref) {
  return SecureMediaService();
});

final encryptedMediaHandlerProvider =
    Provider<EncryptedMediaMessageHandler>((ref) {
  final cryptoService = ref.watch(chatCryptoServiceProvider);
  final mediaService = ref.watch(secureMediaServiceProvider);
  return EncryptedMediaMessageHandler(
    cryptoService,
    mediaService,
    FirebaseFirestore.instance,
  );
});

final userBlockRepositoryProvider = Provider<UserBlockRepository>((ref) {
  return UserBlockRepository(FirebaseFirestore.instance);
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final crypto = ref.watch(chatCryptoServiceProvider);
  final chatRepo = ref.watch(chatRepositoryProvider);
  final mediaHandler = ref.watch(encryptedMediaHandlerProvider);
  final userBlockRepo = ref.watch(userBlockRepositoryProvider);
  return MessageRepository(FirebaseFirestore.instance, userRepo, crypto,
      chatRepo, mediaHandler, userBlockRepo);
});
