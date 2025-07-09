enum FeedSortType {
  hot('hot', 'Hot'),
  latest('latest', 'Latest'),
  top('top', 'Top'),
  trending('trending', 'Trending');

  final String value;
  final String displayName;

  const FeedSortType(this.value, this.displayName);

  static FeedSortType fromString(String value) {
    return FeedSortType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FeedSortType.hot,
    );
  }
}
