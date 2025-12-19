import 'package:flutter_test/flutter_test.dart';
import 'package:herdapp/features/social/feed/public_feed/view/providers/public_feed_provider.dart';
import 'package:riverpod/riverpod.dart';

/// This is a lightweight regression test for the Riverpod 3 migration.
///
/// The old feed wiring returned a controller whose internal state mutations
/// were not observable by Riverpod, which could cause the UI to stay blank
/// until an unrelated rebuild (like tab switching).
///
/// This test asserts we have a real Notifier-style state provider that can
/// be created in isolation.
void main() {
  test('publicFeedStateProvider can be created', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(publicFeedStateProvider);
    expect(state.posts, isEmpty);
    expect(state.isLoading, false);
  });
}
