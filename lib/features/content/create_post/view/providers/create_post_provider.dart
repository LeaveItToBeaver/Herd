import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/content/create_post/data/create_post_repository.dart';

final createPostRepositoryProvider = Provider<CreatePostRepository>((ref) {
  return CreatePostRepository();
});
