import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/edit_user/view/providers/state/edit_profile_state.dart';

import '../../../user/data/models/user_model.dart';
import '../../../user/data/repositories/user_repository.dart';

final editProfileProvider =
StateNotifierProvider.family<EditProfileNotifier, EditProfileState, UserModel>(
      (ref, user) {
    final userRepository = ref.watch(userRepositoryProvider);
    return EditProfileNotifier(userRepository: userRepository, user: user);
  },
);
