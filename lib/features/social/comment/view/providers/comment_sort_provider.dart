import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_sort_provider.g.dart';

@riverpod
class CommentSort extends _$CommentSort {
  @override
  String build() => 'hot';

  void set(String sortBy) => state = sortBy;
}
