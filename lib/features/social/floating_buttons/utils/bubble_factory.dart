import 'package:flutter/material.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_type.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

// Factory class for creating common bubble configurations
class BubbleFactory {
  // System bubbles (order 0-99)
  static BubbleConfigState searchBubble({
    String routeName = 'search',
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 10,
    EdgeInsets? padding,
  }) {
    return BubbleConfigState(
      id: 'search',
      type: BubbleType.custom,
      contentType: BubbleContentType.icon,
      icon: Icons.search,
      routeName: routeName,
      order: order,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  static BubbleConfigState notificationsBubble({
    String routeName = 'notifications',
    bool hasNotifications = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? errorColor,
    int order = 20,
    EdgeInsets? padding,
  }) {
    return BubbleConfigState(
      id: 'notifications',
      type: BubbleType.custom,
      contentType: BubbleContentType.icon,
      icon: Icons.notifications_outlined,
      routeName: routeName,
      order: order,
      backgroundColor: hasNotifications
          ? (errorColor?.withValues(alpha: 0.2) ?? backgroundColor)
          : backgroundColor,
      foregroundColor: hasNotifications ? errorColor : foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  static BubbleConfigState profileBubble({
    required String userId,
    required bool isAlt,
    String? imageUrl,
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 30,
    EdgeInsets? padding,
    VoidCallback? customOnTap,
  }) {
    return BubbleConfigState(
      id: 'profile',
      type: BubbleType.custom,
      contentType: imageUrl != null
          ? BubbleContentType.profileImage
          : BubbleContentType.icon,
      icon: Icons.person_outline,
      imageUrl: imageUrl,
      routeName:
          customOnTap == null ? (isAlt ? 'altProfile' : 'publicProfile') : null,
      routeParams: customOnTap == null ? {'id': userId} : null,
      onTap: customOnTap,
      order: order,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  // static BubbleConfigState feedToggleBubble({
  //   required bool isAltFeed,
  //   required VoidCallback onToggle,
  //   Color? backgroundColor,
  //   Color? foregroundColor,
  //   int order = 100,
  //   EdgeInsets? padding,
  // }) {
  //   return BubbleConfigState(
  //     id: 'feedToggle',
  //     type: BubbleType.custom,
  //     contentType: BubbleContentType.icon,
  //     icon: isAltFeed ? Icons.public : Icons.groups_2,
  //     onTap: onToggle,
  //     order: order,
  //     isLarge: true,
  //     backgroundColor: backgroundColor,
  //     foregroundColor: foregroundColor,
  //     padding: padding ?? const EdgeInsets.all(4),
  //   );
  // }

  // Custom bubbles (order 200-499)
  static BubbleConfigState herdBubble({
    required String herdId,
    required String name,
    String? coverImageUrl,
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 300,
    EdgeInsets? padding,
    VoidCallback? customOnTap,
  }) {
    return BubbleConfigState(
      id: herdId,
      type: BubbleType.custom,
      contentType: coverImageUrl != null
          ? BubbleContentType.herdCoverImage
          : BubbleContentType.text,
      text: name.isNotEmpty ? name[0].toUpperCase() : '?',
      imageUrl: coverImageUrl,
      routeName: customOnTap == null ? 'herd' : null,
      routeParams: customOnTap == null ? {'id': herdId} : null,
      onTap: customOnTap,
      order: order,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  static BubbleConfigState customActionBubble({
    required String id,
    required IconData icon,
    String? routeName,
    Map<String, String>? routeParams,
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 400,
    bool isLarge = false,
    EdgeInsets? padding,
  }) {
    return BubbleConfigState(
      id: id,
      type: BubbleType.custom,
      contentType: BubbleContentType.icon,
      icon: icon,
      routeName: routeName,
      routeParams: routeParams,
      onTap: onTap,
      order: order,
      isLarge: isLarge,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  // Chat bubbles (order 500+)
  static BubbleConfigState chatBubble({
    required String chatId,
    required String name,
    String? imageUrl,
    String? lastMessage,
    int? unreadCount,
    bool isOnline = false,
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 500,
    EdgeInsets? padding,
    VoidCallback? customOnTap,
  }) {
    return BubbleConfigState(
      id: chatId,
      type: BubbleType.chat,
      contentType: imageUrl != null
          ? BubbleContentType.profileImage
          : BubbleContentType.text,
      text: name.isNotEmpty ? name[0].toUpperCase() : '?',
      imageUrl: imageUrl,
      onTap: customOnTap,
      order: order,
      isChatBubble: true,
      chatId: chatId,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      isOnline: isOnline,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding ?? const EdgeInsets.all(4),
    );
  }

  static BubbleConfigState draggableChatBubble({
    required String chatId,
    required String name,
    String? imageUrl,
    String? lastMessage,
    int? unreadCount,
    bool isOnline = false,
    Color? backgroundColor,
    Color? foregroundColor,
    int order = 500,
    EdgeInsets? padding,
    VoidCallback? customOnTap,
  }) {
    return chatBubble(
      chatId: chatId,
      name: name,
      imageUrl: imageUrl,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      isOnline: isOnline,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      order: order,
      padding: padding ?? const EdgeInsets.all(4),
      customOnTap: customOnTap,
    ).copyWith(
      type: BubbleType.draggable,
      isDraggable: true,
    );
  }

  // Demo/placeholder bubbles
  static List<BubbleConfigState> generateDemoCommunityBubbles({
    int count = 15,
    int startOrder = 1000,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return List.generate(count, (i) {
      return BubbleConfigState(
        id: 'community_$i',
        type: BubbleType.chat,
        contentType: BubbleContentType.text,
        text: '${i + 1}',
        order: startOrder + i,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        isChatBubble: true,
        chatId: 'demo_chat_$i',
        // Random demo data
        unreadCount: i % 3 == 0 ? i + 1 : null,
        isOnline: i % 4 == 0,
      );
    });
  }

  // Conditional visibility helpers
  static BubbleConfigState conditionalBubble({
    required BubbleConfigState baseBubble,
    required bool Function() condition,
  }) {
    return baseBubble.copyWith(
      visibilityCondition: condition,
    );
  }

  static BubbleConfigState hiddenBubble({
    required BubbleConfigState baseBubble,
  }) {
    return baseBubble.copyWith(
      isVisible: false,
    );
  }
}
