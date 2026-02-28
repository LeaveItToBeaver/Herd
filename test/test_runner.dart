import 'package:flutter_test/flutter_test.dart';

import 'features/social/chat_messaging/message_repository_test.dart'
    as message_repo_tests;
import 'features/content/post/post_repository_test.dart' as post_repo_tests;
import 'features/user/user_model_test.dart' as user_model_tests;
import 'widgets/post_widget_test.dart' as post_widget_tests;
import 'features/customization_tests/customization_model_test.dart'
    as customization_tests;

void main() {
  group('All Tests', () {
    group('Chat Tests', () {
      message_repo_tests.main();
    });

    group('Post Tests', () {
      post_repo_tests.main();
      post_widget_tests.main();
    });

    group('User Tests', () {
      user_model_tests.main();
    });

    group('Customization Tests', () {
      customization_tests.main();
    });
  });
}
