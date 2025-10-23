import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';

final expandedCommentsProvider =
    StateNotifierProvider<ExpandedCommentsNotifier, ExpandedCommentsState>(
        (ref) {
  return ExpandedCommentsNotifier();
});

class ExpandedCommentsNotifier extends StateNotifier<ExpandedCommentsState> {
  ExpandedCommentsNotifier() : super(ExpandedCommentsState.initial());

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
