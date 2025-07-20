import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/view/providers/state/profile_state.dart';

import '../../profile_controller.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileState>(
  () => ProfileController(),
);
