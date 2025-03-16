import 'dart:math';

class HotAlgorithm {
  /// Epoch time (an arbitrary starting point for time measurements)
  /// This is set to a recent timestamp for simplicity
  static final DateTime _epoch = DateTime(2023, 1, 1);

  /// Natural log of 10, used for converting natural log to log10
  static const double ln10 = 2.302585092994046;

  /// Time weight factor (in seconds)
  /// Lower values make votes more impactful compared to time
  static const double _timeWeight = 45000;

  /// Calculate the "hot" score for a post
  ///
  /// [votes] Net votes (upvotes - downvotes)
  /// [createdAt] When the post was created
  /// [decayFactor] Optional parameter to adjust how quickly posts decay (default: 1.0)
  ///
  /// Returns a double score that can be used for sorting
  static double calculateHotScore(int votes, DateTime createdAt, {double decayFactor = 1.0}) {
    // Handle edge cases
    int adjustedVotes = votes;
    if (adjustedVotes <= 0) adjustedVotes = 1; // Ensure we don't take log of zero or negative

    // Calculate seconds since epoch
    final secondsSinceEpoch = createdAt.difference(_epoch).inSeconds;

    // Apply Reddit's formula: log10(votes) + (time / timeWeight)
    // Use natural log and convert to log10
    final double voteScore = log(adjustedVotes) / ln10;
    final double timeScore = secondsSinceEpoch / (_timeWeight * decayFactor);

    return voteScore + timeScore;
  }

  /// Sort a list of posts by their hot score
  ///
  /// [posts] List of posts to sort
  /// [getVotes] Function to extract net votes from a post
  /// [getCreatedAt] Function to extract creation time from a post
  /// [decayFactor] Optional parameter to adjust how quickly posts decay
  ///
  /// Returns a new list sorted by hot score in descending order
  static List<T> sortByHotScore<T>(
      List<T> posts,
      int Function(T post) getVotes,
      DateTime Function(T post) getCreatedAt,
      {double decayFactor = 1.0}
      ) {
    final sortedPosts = List<T>.from(posts);
    sortedPosts.sort((a, b) {
      final scoreA = calculateHotScore(getVotes(a), getCreatedAt(a), decayFactor: decayFactor);
      final scoreB = calculateHotScore(getVotes(b), getCreatedAt(b), decayFactor: decayFactor);
      return scoreB.compareTo(scoreA); // Descending order
    });
    return sortedPosts;
  }
}