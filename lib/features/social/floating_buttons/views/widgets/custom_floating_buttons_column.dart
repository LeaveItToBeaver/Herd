import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/ui/customization/view/providers/ui_customization_provider.dart';

class CustomFloatingButtonsColumn extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;

  const CustomFloatingButtonsColumn({
    super.key,
    required this.showProfileBtn,
    required this.showSearchBtn,
    required this.showNotificationsBtn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFeed = ref.watch(currentFeedProvider);
    final customization = ref.watch(uiCustomizationProvider).value;
    final notifications =
        ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));

    // Get custom theme colors or fall back to defaults
    final appTheme = customization?.appTheme;
    final primaryColor =
        appTheme?.getPrimaryColor() ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = appTheme?.getSecondaryColor() ??
        Theme.of(context).colorScheme.secondary;
    final surfaceColor = appTheme?.getSurfaceColor() ?? Colors.black;
    final onSurfaceColor = appTheme?.getTextColor() ?? Colors.white;

    // Theme effects
    final enableGlassmorphism = appTheme?.enableGlassmorphism ?? false;
    final enableShadows = appTheme?.enableShadows ?? true;
    final shadowIntensity = appTheme?.shadowIntensity ?? 1.0;

    final bool bothButtonsVisible = showProfileBtn && showSearchBtn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile button
        if (showProfileBtn)
          Padding(
            padding: EdgeInsets.only(bottom: bothButtonsVisible ? 8.0 : 0.0),
            child: _buildFloatingButton(
              heroTag: "floatingProfileBtn",
              icon: Icons.person,
              color:
                  currentFeed == FeedType.alt ? secondaryColor : primaryColor,
              backgroundColor: surfaceColor,
              onPressed: () {
                final navService = ref.read(navigationServiceProvider);
                if (!navService.canNavigate) return;

                HapticFeedback.mediumImpact();
                final currentUser = ref.read(authProvider);
                if (currentUser?.uid != null) {
                  if (currentFeed == FeedType.alt) {
                    context.pushNamed('altProfile',
                        pathParameters: {'id': currentUser!.uid});
                  } else {
                    context.pushNamed('publicProfile',
                        pathParameters: {'id': currentUser!.uid});
                  }
                } else {
                  context.go("/login");
                }
              },
              enableGlassmorphism: enableGlassmorphism,
              enableShadows: enableShadows,
              shadowIntensity: shadowIntensity,
            ),
          ),

        // Notifications button
        if (showNotificationsBtn)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildFloatingButton(
              heroTag: "floatingNotificationsBtn",
              icon: Icons.notifications,
              color: notifications.hasValue ? primaryColor : onSurfaceColor,
              backgroundColor: surfaceColor,
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.pushNamed('notifications');
              },
              enableGlassmorphism: enableGlassmorphism,
              enableShadows: enableShadows,
              shadowIntensity: shadowIntensity,
            ),
          ),

        // Search button
        if (showSearchBtn)
          _buildFloatingButton(
            heroTag: "floatingSearchBtn",
            icon: Icons.search,
            color: onSurfaceColor,
            backgroundColor: surfaceColor,
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.pushNamed('search');
            },
            enableGlassmorphism: enableGlassmorphism,
            enableShadows: enableShadows,
            shadowIntensity: shadowIntensity,
          ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required String heroTag,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required bool enableGlassmorphism,
    required bool enableShadows,
    required double shadowIntensity,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: enableGlassmorphism
            ? backgroundColor.withValues(alpha: 0.7)
            : backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: enableGlassmorphism
            ? Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
        boxShadow: enableShadows
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3 * shadowIntensity),
                  blurRadius: 12 * shadowIntensity,
                  offset: Offset(0, 4 * shadowIntensity),
                ),
                if (enableGlassmorphism)
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: enableGlassmorphism
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _buildButtonContent(heroTag, icon, color, onPressed),
              )
            : _buildButtonContent(heroTag, icon, color, onPressed),
      ),
    );
  }

  Widget _buildButtonContent(
      String heroTag, IconData icon, Color color, VoidCallback onPressed) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: Colors.transparent,
      elevation: 0,
      mini: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
