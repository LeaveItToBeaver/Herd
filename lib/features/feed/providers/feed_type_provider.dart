import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedType { public, private }

final currentFeedProvider = StateProvider<FeedType>((ref) => FeedType.public);