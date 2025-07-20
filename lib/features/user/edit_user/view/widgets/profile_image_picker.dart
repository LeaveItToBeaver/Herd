import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../../core/services/image_helper.dart';
import '../../../user_profile/data/models/user_model.dart';
import '../../../user_profile/view/widgets/user_profile_image.dart';
import '../providers/edit_profile_provider.dart';

class ProfileImagePicker extends ConsumerWidget {
  final UserModel user;

  const ProfileImagePicker({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider(user));

    return GestureDetector(
      onTap: () async {
        final file = await ImageHelper.pickImageFromGallery(
          context: context,
          cropStyle: CropStyle.circle,
          title: 'Profile Image',
        );
        ref.read(editProfileProvider(user).notifier).profileImageChanged(file);
      },
      child: UserProfileImage(
        radius: 80.0,
        profileImageUrl: user.profileImageURL,
        profileImage: state.profileImage,
      ),
    );
  }
}
