// Provider for the repository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});
