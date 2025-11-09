import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_type_provider.g.dart';

enum FeedType { public, alt }

@riverpod
class CurrentFeed extends _$CurrentFeed {
  @override
  FeedType build() {
    return FeedType.public;
  }

  void setFeedType(FeedType feedType) {
    state = feedType;
  }

  void toggle() {
    state = state == FeedType.public ? FeedType.alt : FeedType.public;
  }
}