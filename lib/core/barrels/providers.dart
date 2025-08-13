//Core Providers
export 'package:herdapp/core/providers/exception_logger_provider.dart';

//Auth Providers
export 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
export 'package:herdapp/features/user/auth/view/providers/email_verification_provider.dart';
export 'package:herdapp/features/user/auth/view/providers/firebase_auth_provider.dart';
export 'package:herdapp/features/user/auth/view/providers/state/sign_up_form_state.dart';
export 'package:herdapp/features/user/auth/data/repositories/auth_repository.dart';

//User Profile Providers
export 'package:herdapp/features/user/user_profile/view/providers/alt_connection_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/image_loading_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/profile_controller_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/profile_customization_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/profile_navigation_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/user_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/user_settings_notifier.dart';
export 'package:herdapp/features/user/user_profile/view/providers/user_settings_provider.dart';
export 'package:herdapp/features/user/user_profile/view/providers/state/profile_state.dart';
export 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

//Edit User Providers
export 'package:herdapp/features/user/edit_user/view/providers/edit_profile_provider.dart';
export 'package:herdapp/features/user/edit_user/alt_profile/view/providers/edit_alt_profile_notifier.dart';
export 'package:herdapp/features/user/edit_user/alt_profile/view/providers/state/edit_alt_profile_state.dart';
export 'package:herdapp/features/user/edit_user/public_profile/view/providers/edit_public_profile_notifier.dart';

//Post Providers
export 'package:herdapp/features/content/post/view/providers/post_provider.dart';
export 'package:herdapp/features/content/post/view/providers/pinned_post_provider.dart';
export 'package:herdapp/features/content/post/view/providers/state/post_interaction_notifier.dart';
export 'package:herdapp/features/content/post/view/providers/state/post_interaction_state.dart';
export 'package:herdapp/features/content/post/view/providers/state/post_state.dart';
export 'package:herdapp/features/content/post/data/repositories/post_repository.dart';

//Create Post Providers
export 'package:herdapp/features/content/create_post/view/providers/create_post_provider.dart';
export 'package:herdapp/features/content/create_post/view/providers/state/create_post_state.dart';

//Draft Providers
export 'package:herdapp/features/content/drafts/view/providers/draft_provider.dart';
export 'package:herdapp/features/content/drafts/data/repositories/draft_repository.dart';

//Comment Providers
export 'package:herdapp/features/social/comment/view/providers/comment_providers.dart';
export 'package:herdapp/features/social/comment/view/providers/reply_providers.dart';
export 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';
export 'package:herdapp/features/social/comment/view/providers/state/reply_state.dart';
export 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';

//Feed Providers
export 'package:herdapp/features/social/feed/providers/feed_type_provider.dart';
export 'package:herdapp/features/social/feed/providers/trending_posts_provider.dart';
export 'package:herdapp/features/social/feed/alt_feed/view/providers/alt_feed_provider.dart';
export 'package:herdapp/features/social/feed/alt_feed/view/providers/state/alt_feed_states.dart';
export 'package:herdapp/features/social/feed/public_feed/view/providers/public_feed_provider.dart';
export 'package:herdapp/features/social/feed/public_feed/view/providers/state/public_feed_state.dart';
export 'package:herdapp/features/social/feed/data/repositories/feed_repository.dart';

//Notification Providers
export 'package:herdapp/features/social/notifications/view/providers/notification_provider.dart';
export 'package:herdapp/features/social/notifications/view/providers/notification_settings_notifier.dart';
export 'package:herdapp/features/social/notifications/view/providers/state/notification_filter_state.dart';
export 'package:herdapp/features/social/notifications/view/providers/state/notification_state.dart';
export 'package:herdapp/features/social/notifications/data/repositories/notification_repository.dart';

//Mention Providers
export 'package:herdapp/features/social/mentions/view/providers/mentions_provider.dart';

//Floating Button and Navigation Providers
export 'package:herdapp/features/social/floating_buttons/views/providers/navigation_provider.dart';
export 'package:herdapp/features/social/floating_buttons/views/providers/navigation_service_provider.dart';
export 'package:herdapp/features/ui/navigation/view/providers/bottom_nav_bar_provider.dart';

//Search Providers
export 'package:herdapp/features/community/search/search_controller.dart';
export 'package:herdapp/features/community/search/view/providers/state/search_state.dart';

//Herd Providers
export 'package:herdapp/features/community/herds/view/providers/herd_data_providers.dart';
export 'package:herdapp/features/community/herds/view/providers/herd_feed_providers.dart';
export 'package:herdapp/features/community/herds/view/providers/herd_moderation_providers.dart';
export 'package:herdapp/features/community/herds/view/providers/herd_permission_providers.dart';
export 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';
export 'package:herdapp/features/community/herds/view/providers/herd_repository_provider.dart';
export 'package:herdapp/features/community/herds/view/providers/state/herd_feed_state.dart';
export 'package:herdapp/features/community/herds/data/repositories/herd_repository.dart';

//Moderation Providers
export 'package:herdapp/features/community/moderation/view/providers/moderation_providers.dart';
export 'package:herdapp/features/community/moderation/data/repositories/moderation_repository.dart';

//UI Customization Providers
export 'package:herdapp/features/ui/customization/view/providers/optimistic_slider_provider.dart';
export 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';
export 'package:herdapp/features/ui/customization/view/providers/ui_customization_slider_providers.dart';
export 'package:herdapp/features/ui/customization/data/repositories/ui_customization_repository.dart';

// Drag State Providers
export 'package:herdapp/features/social/floating_buttons/views/providers/drag_state_provider.dart';
export 'package:herdapp/features/social/floating_buttons/views/providers/chat_overlay_provider.dart';

//Chat Messaging Providers
export 'package:herdapp/features/social/chat_messaging/view/providers/active_chat_provider.dart';
export 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';
export 'package:herdapp/features/social/chat_messaging/view/providers/e2ee_chat_provider.dart';
export 'package:herdapp/features/social/chat_messaging/view/providers/state/chat_state.dart';
export 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
export 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';
export 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
