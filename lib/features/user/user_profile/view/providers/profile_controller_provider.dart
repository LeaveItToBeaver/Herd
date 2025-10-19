import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/user/user_profile/view/providers/state/profile_state.dart';

import '../../profile_controller.dart';

part 'profile_controller_provider.g.dart';

@riverpod
class ProfileControllerNotifier extends _$ProfileControllerNotifier {
  @override
  Future<ProfileState> build() async {
    return ref.read(profileControllerProvider.future);
  }
}
