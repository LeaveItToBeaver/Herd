import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/floating_buttons/utils/navigation_service.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});
