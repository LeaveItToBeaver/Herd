import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/floating_buttons/utils/navigation_service.dart';

part 'navigation_service_provider.g.dart';

@riverpod
NavigationService navigationService(Ref ref) {
  return NavigationService();
}
