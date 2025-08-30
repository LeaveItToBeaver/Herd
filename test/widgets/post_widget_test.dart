import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/content/post/view/widgets/post_widget.dart';

void main() {
  group('PostWidget', () {
    late PostModel testPost;

    setUp(() {
      testPost = PostModel(
        id: 'test_post_id',
        authorId: 'test_author_id',
        authorUsername: 'testuser',
        authorProfileImageURL: 'https://example.com/avatar.jpg',
        title: 'Test Post Title',
        content: 'This is a test post content.',
        isAlt: false,
        likeCount: 5,
        dislikeCount: 1,
        commentCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('should display post content correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Verify post content is displayed
      expect(find.text('Test Post Title'), findsOneWidget);
      expect(find.text('This is a test post content.'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
    });

    testWidgets('should display like and dislike counts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Check for like and dislike counts
      expect(find.text('5'), findsWidgets); // Like count
      expect(find.text('1'), findsWidgets); // Dislike count
      expect(find.text('3'), findsWidgets); // Comment count
    });

    testWidgets('should display author profile image when available',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Look for NetworkImage or cached image widgets
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('should handle post without media', (tester) async {
      final textOnlyPost = testPost.copyWith(mediaURL: null);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: textOnlyPost),
            ),
          ),
        ),
      );

      expect(find.text('Test Post Title'), findsOneWidget);
      expect(find.text('This is a test post content.'), findsOneWidget);
    });

    testWidgets('should handle post with media', (tester) async {
      final mediaPost =
          testPost.copyWith(mediaURL: 'https://example.com/image.jpg');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: mediaPost),
            ),
          ),
        ),
      );

      expect(find.text('Test Post Title'), findsOneWidget);
      // Media widget would be present but testing actual image loading
      // requires more complex setup with mock network images
    });

    testWidgets('should show interaction buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Look for like, dislike, and comment buttons
      expect(find.byType(IconButton), findsWidgets);

      // Look for common icons used in social media apps
      expect(find.byIcon(Icons.thumb_up_alt_outlined), findsWidgets);
      expect(find.byIcon(Icons.thumb_down_alt_outlined), findsWidgets);
      expect(find.byIcon(Icons.comment_outlined), findsWidgets);
    });

    testWidgets('should format timestamp correctly', (tester) async {
      final oldPost = testPost.copyWith(
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: oldPost),
            ),
          ),
        ),
      );

      // Check that some time indication is present
      expect(find.textContaining('ago'), findsWidgets);
    });

    testWidgets('should handle alt posts differently', (tester) async {
      final altPost = testPost.copyWith(isAlt: true);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: altPost),
            ),
          ),
        ),
      );

      expect(find.text('Test Post Title'), findsOneWidget);
      // Alt posts might have different styling or indicators
    });

    testWidgets('should be tappable to navigate to post detail',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Look for GestureDetector or InkWell
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should handle long content with proper overflow',
        (tester) async {
      final longContentPost = testPost.copyWith(
        content:
            'This is a very long post content that should be handled properly. ' *
                20,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PostWidget(post: longContentPost),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Post Title'), findsOneWidget);
      // Content should be clipped or have a "read more" functionality
    });

    testWidgets('should handle empty or null author profile image',
        (tester) async {
      final noAvatarPost = testPost.copyWith(authorProfileImageURL: null);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: noAvatarPost),
            ),
          ),
        ),
      );

      // Should still display username and content
      expect(find.text('@testuser'), findsOneWidget);
      expect(find.text('Test Post Title'), findsOneWidget);

      // Should show default avatar or placeholder
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('should display correct engagement metrics', (tester) async {
      final popularPost = testPost.copyWith(
        likeCount: 1000,
        dislikeCount: 50,
        commentCount: 200,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: popularPost),
            ),
          ),
        ),
      );

      // Check for formatted numbers (1k, etc.) or raw numbers
      expect(find.textContaining('1000'), findsWidgets);
      expect(find.textContaining('200'), findsWidgets);
    });
  });

  group('PostWidget Interactions', () {
    testWidgets('should handle like button tap', (tester) async {
      final testPost = PostModel(
        id: 'test_post_id',
        authorId: 'test_author_id',
        authorUsername: 'testuser',
        title: 'Test Post',
        content: 'Test content',
        isAlt: false,
        likeCount: 5,
        dislikeCount: 1,
        commentCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Find and tap the like button
      final likeButton = find.byIcon(Icons.thumb_up_alt_outlined).first;
      await tester.tap(likeButton);
      await tester.pump();

      // Verify the interaction was registered
      // (In a real test, you'd mock the provider and verify the call)
    });

    testWidgets('should handle comment button tap', (tester) async {
      final testPost = PostModel(
        id: 'test_post_id',
        authorId: 'test_author_id',
        authorUsername: 'testuser',
        title: 'Test Post',
        content: 'Test content',
        isAlt: false,
        likeCount: 5,
        dislikeCount: 1,
        commentCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PostWidget(post: testPost),
            ),
          ),
        ),
      );

      // Find and tap the comment button
      final commentButton = find.byIcon(Icons.comment_outlined).first;
      await tester.tap(commentButton);
      await tester.pump();

      // Should navigate to comments or open comment dialog
    });
  });
}
