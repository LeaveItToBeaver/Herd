import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

import '../providers/edit_profile_provider.dart';
import '../widgets/cover_image_picker.dart';
import '../widgets/edit_profile_form.dart';
import '../widgets/profile_image_picker.dart';

class EditProfileScreen extends ConsumerWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider(user));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (state.isSubmitting) const LinearProgressIndicator(),
              CoverImagePicker(user: user),
              const SizedBox(height: 20),
              ProfileImagePicker(user: user),
              const SizedBox(height: 32),
              EditProfileForm(user: user),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: () {
                    if (!state.isSubmitting) {
                      ref.read(editProfileProvider(user).notifier).submit(user);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color(0xffffe7c2),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
