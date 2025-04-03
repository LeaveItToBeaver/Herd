import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedType { public, alt }

final currentFeedProvider = StateProvider<FeedType>((ref) => FeedType.public);