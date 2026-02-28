import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';

part 'expanded_comments_provider.g.dart';

@riverpod
class ExpandedComments extends _$ExpandedComments {
  @override
  ExpandedCommentsState build() => ExpandedCommentsState.initial();

  void toggleExpanded(String commentId) {
    final expandedIds = Set<String>.from(state.expandedCommentIds);
    if (expandedIds.contains(commentId)) {
      expandedIds.remove(commentId);
    } else {
      expandedIds.add(commentId);
    }
    state = state.copyWith(expandedCommentIds: expandedIds);
  }

  void collapseAll() {
    state = state.copyWith(expandedCommentIds: {});
  }
}
