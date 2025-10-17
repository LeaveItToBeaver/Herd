import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/content/create_post/data/create_post_repository.dart';

part 'create_post_provider.g.dart';

@riverpod
CreatePostRepository createPostRepository(Ref ref) {
  return CreatePostRepository();
}
