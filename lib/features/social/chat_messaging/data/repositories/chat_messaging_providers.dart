import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/e2ee_key_manager.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

final chatCryptoServiceProvider = Provider<ChatCryptoService>((ref) {
  return ChatCryptoService(const FlutterSecureStorage());
});

final e2eeKeyManagerProvider = Provider<E2EEKeyManager>((ref) {
  final cryptoService = ref.watch(chatCryptoServiceProvider);
  return E2EEKeyManager(
    const FlutterSecureStorage(),
    cryptoService,
    FirebaseFirestore.instance,
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ChatRepository(FirebaseFirestore.instance, userRepo);
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final crypto = ref.watch(chatCryptoServiceProvider);
  final chatRepo = ref.watch(chatRepositoryProvider);
  return MessageRepository(
      FirebaseFirestore.instance, userRepo, crypto, chatRepo);
});
