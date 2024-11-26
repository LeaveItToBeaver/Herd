import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../core/services/image_helper.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/view/widgets/user_cover_image.dart';
import '../providers/edit_profile_provider.dart';

class CoverImagePicker extends ConsumerWidget {
  final UserModel user;

  const CoverImagePicker({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider(user));

    return GestureDetector(
      onTap: () async {
        final file = await ImageHelper.pickImageFromGallery(
          context: context,
          cropStyle: CropStyle.rectangle,
          title: 'Cover Photo',
        );
        ref.read(editProfileProvider(user).notifier).coverImageChanged(file);
      },
      child: Stack(
        children: [
          UserCoverImage(
            coverImageUrl: user.coverImageURL,
            coverFile: state.coverImage,
            isSelected: true,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Card(
                color: Colors.white.withAlpha(150),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tap to edit cover photo",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
